/*
 * Copyright (C) 2020 Curity AB. All rights reserved.
 *
 * The contents of this file are the property of Curity AB.
 * You may not copy or use this file, in either source code
 * or executable form, except in compliance with terms
 * set by Curity AB.
 *
 * For further information, please contact Curity AB.
 */

/**
 * Create a Curity object that can handle the user authorization flows.
 * @param viewsElement DOM element to be used for rendering views
 * @param codeElement DOM element to show the JSON responses from the server
 * @param callback to be called with an object containing the code and state for the token request
 * @param apiFetch async function to perform API requests
 * @constructor
 */

function Curity(viewsElement, codeElement, callback, apiFetch) {

    const formElement = document.createElement('div');
    viewsElement.append(formElement);

    const spinnerElement = document.createElement('div');
    spinnerElement.className = 'siimple--display-none';
    viewsElement.append(spinnerElement);

    function messageHandler() {
        const state = {resumeAction: null};
        window.addEventListener("message", async event => {
            console.log("Received postMessage", event);
            if (event.source !== externalWindow) {
                console.log('External browser message handler ignoring postMessage from unknown window.')
                return;
            }
            if (!state.resumeAction) {
                console.warn("Resume action has not been set");
            }
            if (event.source === externalWindow && (typeof event.data) === 'string' && state.resumeAction) {
                await state.resumeAction(event.data);
                state.resumeAction = null
                const w = externalWindow
                externalWindow = null
                setTimeout(() => w.close(), 2000)
            }
        });
        return resumeAction => state.resumeAction = resumeAction
    }

    /**
     * A function that accepts another function (the resume action) that takes the data posted by the
     * other window to resume the external-browser-flow.
     * @type {function(*): *}
     */
    const setResumeAction = messageHandler();
    let externalWindow;  /* : Window | undefined */

    /**
     * An object containing the data currently being displayed ({ model, text, status })
     */
    let currentPageData;

    let followRedirects = false;

    window.addEventListener('popstate', event => tryRestorePageFromHistory(event.state));

    /**
     * Controls whether some of the default component views are replaced by others that take into account more details of
     * the API representations, such as specific action 'kind' values.
     */
    this.enableEnhancedMode = function (enabled) {
        views = enabled ? enhancedViews : defaultViews;
        refreshCurrentPage();
    }

    /**
     * Controls whether the client should follow a redirection-step automatically. Note that is most likely the behavior
     * of a production client application. The option to not follow redirects is here for demo purposes.
     */
    this.followRedirects = function (follow) {
        followRedirects = follow;
    }

    this.authorizeUser = (authorizeUrl) => {
        apiRequest(authorizeUrl);
    }

    this.goTo = (url) => {
        apiRequest(url);
    }

    function generatePage(json, autoFollowLinks) {
        json = json || {};
        let components = [];

        components.push(...generateMessages(json));

        if (json.type === 'authentication-step' || json.type === 'registration-step' || json.type === 'redirection-step'
            || json.type === 'user-consent-step' || json.type == 'consentor-step') {
            components.push(...generateActions(json, autoFollowLinks));
        } else if (json.type === 'oauth-authorization-response') {
            components.push(callback(json));
        } else if (json.type === 'polling-step') {
            components.push(...views.Polling(json, autoFollowLinks));
        } else if (json.type) {
            components.push(views.ErrorMessage(`Cannot render type ${json.type}`));
        } else {
            components.push(views.ErrorMessage(`Cannot render response missing a type`));
        }

        components.push(...generateLinks(json));

        return components;
    }

    function generateMessages(json) {
        if (!json.messages || json.messages.length === 0) {
            return [];
        }

        return json.messages.map(message => views.Message(message));
    }

    function generateLinks(json) {

        if (!json.links || json.links.length === 0) {
            return [];
        }

        return [
            views.Ruler(),
            ...json.links.map(link => {
                if (link.type && link.type.startsWith('image/') || link.href.startsWith('data:image')) {
                    return views.ImageLink(link);
                } else {
                    return views.ButtonForLink(link);
                }
            })
        ];
    }

    function generateActions(json, autoFollowLinks) {
        console.log(`on ${json.type}`);

        const components = [];
        const actions = json.actions || [];

        if (followRedirects && actions.length === 1 && actions[0].kind === 'redirect') {
            setTimeout(() => apiRequestForFormAction(actions[0]));
            return [views.Spinner()];
        }

        // don't show foldable selectors if there's only one action that's not of kind "cancel".
        const foldActions = actions.filter(a => a.kind !== 'cancel').length > 1;
        actions.map((action) => {
            if (action.template === 'selector') {
                return [action, views.Selector(action, foldActions), true];
            } else if (action.template === 'form') {
                if (action.kind === 'redirect') {
                    return [action, views.Redirect(action, foldActions), false];
                }
                // try to avoid using a folder if this is not a form with fields
                let mayFold = action.kind !== 'cancel'
                    && Array.isArray(action.model.fields)
                    && action.model.fields.length > 0;
                return [action, views.ActionForm(action, foldActions && mayFold), mayFold];
            } else if (action.template === 'client-operation') {
                if (action.model.name === 'external-browser-flow') {
                    return [action, launchExternalBrowserFlow(action, autoFollowLinks), false];
                } else if (action.model.name === 'bankid') {
                    return [action, views.LaunchUrl(action.model.arguments.href, action, autoFollowLinks), false];
                } else {
                    return [action, views.ErrorMessage(`Unsupported client operation '${action.model.name}'`), false];
                }
            } else {
                return [action, views.ErrorMessage(`Cannot render template '${action.template}'`), false];
            }
        }).forEach((entry) => {
            let [action, actionElement, mayFold] = entry;
            if (foldActions && mayFold) {
                let title = action.title || action.kind;
                components.push(views.Foldable(title, actionElement));
            } else {
                components.push(actionElement);
            }
        });

        return components;
    }

    function launchExternalBrowserFlow(action, autoFollowLinks) {
        const windowLocationUrl = new URL(window.location)
        const launchUrl = `${action.model.arguments.href}&for_origin=${encodeURIComponent(windowLocationUrl.origin)}`

        // this will run when the other window posts back a message to this window containing a nonce
        setResumeAction(nonce => {
            console.log("Received nonce", nonce);
            let foundContext = false
            // find the action that has the context field we need to fill in with a nonce and set its value
            action.model.continueActions.forEach(subAction => {
                if (subAction.template === 'form' && Array.isArray(subAction.model.fields)) {
                    subAction.model.fields.forEach(field => {
                        if (field.type === 'context' && field.name === '_resume_nonce') {
                            field.value = nonce;
                            foundContext = true;
                        }
                    });
                }
            });

            if (!foundContext) {
                console.warn("Received a nonce to continue after browser-flow, but could not find any " +
                    "context field in the continueActions");
            }

            continueToNestedActions(action, autoFollowLinks);
        });

        const launchExternalWindow = () => {
            console.log("opening " + launchUrl);
            if (externalWindow && !externalWindow.closed) {
                externalWindow.location = launchUrl;
            } else {
                externalWindow = window.open(launchUrl, "external-browser-window");
                if (!externalWindow) {
                    console.log("failed to open external window, flow will not complete successfully")
                    alert(
                        "Unable to open additional window required to continue the authentication flow, probably due to pop-ups being blocked.\n" +
                        "Please enable pop-ups for this site and restart the authentication flow."
                    )
                }
            }
        }

        if (autoFollowLinks) {
            launchExternalWindow();
        }

        const button = views.Button({
            name: 'launch',
            label: action.title,
            onClick: launchExternalWindow,
            disabled: autoFollowLinks,
        });

        return button
    }

    function continueToNestedActions(action, autoFollowLinks, actionsKey) {
        let nextActions = action && action.model[actionsKey || 'continueActions'];
        if (nextActions && nextActions.length > 0) {
            // will render the same json again, but with actions replaced with the nested actions
            let newModel = deepCopy(currentPageData.model);
            newModel.actions = nextActions;
            showGeneratedPage(generatePage(newModel, autoFollowLinks), currentPageData.status);
            savePage(newModel, currentPageData.text, currentPageData.status);
        } else {
            showGeneratedPage(views.ErrorMessage("No actions to follow after launch"), -1);
        }
    }

    /**
     * Sends an API request.
     * @param link request url
     * @param method (optional) request method
     * @param data (optional) request body
     * @param sourceAction (optional) action that triggered the request ({ model, onInvalidInput }); used to:
     *  1. look for continuation actions if the server instructs the client to stay on the same step
     *  2. notify about input errors if the server responds with with https://curity.se/problems/invalid-input problem
     * @returns {Promise<void>}
     */
    async function apiRequest(link, method, data, sourceAction) {

        // show a spinner but don't remove the current views because we may need to stay on the same page
        spinnerElement.classList.remove('siimple--display-none');
        formElement.classList.add('siimple--display-none');

        let body;
        if (method === 'GET' || method === 'HEAD') {
            body = undefined;
            if (data) {
                // send data in query parameters
                let searchParams = new URLSearchParams(data);
                if (link.includes('?')) {
                    link = `${link}&${searchParams}`;
                } else {
                    link = `${link}?${searchParams}`;
                }
            }
        } else {
            body = data;
        }
        try {
            console.log(`*** FETCH REQUEST: ${link}, ${method}, ${body}`);
            const response = await apiFetch(link, {method, body});
            const text = await response.text();
            console.log(`** FETCH RESPONSE: ${text}`);

            // status codes without a parse-able body
            if (response.status === 204
                || response.status < 200
                || (300 <= response.status && response.status < 400)) {
                codeElement.textContent = text;
                showGeneratedPage([views.ErrorMessage('Nothing to display')], response.status);
                return;
            }
            const json = JSON.parse(text);
            console.log('Parsed JSON: ', json);

            if (response.headers.get('Content-Type') === 'application/problem+json') {
                showJSON(json);
                showProblem(json, response.status, sourceAction && sourceAction.onInvalidInput);
                return;
            }

            if (json.type === 'continue-same-step') {
                continueToNestedActions(sourceAction && sourceAction.model, true)
            } else {
                showJSON(json);
                showGeneratedPage(generatePage(json, true), response.status);
                savePage(json, text, response.status);
            }
        } catch (e) {
            console.error(e);
            codeElement.textContent = '';
            showGeneratedPage([views.ErrorMessage("Invalid response content")], 0);
        } finally {
            spinnerElement.classList.add('siimple--display-none');
            formElement.classList.remove('siimple--display-none');
        }
    }

    /**
     * Sends an API request based on the model of a form action.
     * @param action the form action
     * @param onInvalidInput (optional) a function that is called if the action results in an 'invalid input' error; its
     * only parameter is the 'invalidFields' array as returned in a 'https://curity.se/problems/invalid-input' problem
     * @returns {Promise<void>}
     */
    async function apiRequestForFormAction(action, onInvalidInput) {
        const formBody = new URLSearchParams();
        (action.model.fields || []).forEach(field => {
            if (field.type !== 'checkbox' || field.checked) {
                formBody.append(field.name, field.value || '')
            }
        });
        await apiRequest(action.model.href, action.model.method, formBody, {model: action, onInvalidInput});
    }

    function showGeneratedPage(components, statusCode) {
        console.log(`Will render ${components.length} components`);
        formElement.innerHTML = '';

        const statusHeaderElement = document.createElement('h2');
        statusHeaderElement.textContent = 'Status Code';
        formElement.append(statusHeaderElement);
        formElement.append(views.Button({
            label: `${statusCode}`,
            color: statusCode >= 400 ? 'warning' : 'navy',
            big: true,
            id: 'status-code'
        }));

        formElement.append(views.Ruler());

        components.forEach((component) => {
            if (component) formElement.append(component);
        });
    }

    function showProblem(json, status, onInvalidInput) {

        if (json.type === 'https://curity.se/problems/invalid-input' && onInvalidInput) {
            onInvalidInput(json.invalidFields);
            return;
        }

        let components = [];
        if (json.title) {
            components.push(views.ErrorMessage(json.title));
        } else {
            components.push(views.ErrorMessage(json.type));
        }
        if (Array.isArray(json.messages) && json.messages.length > 0) {
            json.messages.forEach(m => components.push(views.ErrorMessage(m.text)));
        }
        showGeneratedPage(components, status);
    }

    function showJSON(json) {
        codeElement.textContent = JSON.stringify(json, null, 2);
        hljs.highlightBlock(codeElement);
    }

    function savePage(model, text, status) {
        currentPageData = {
            model,
            text,
            status
        }
        window.history.pushState(currentPageData, '');
    }

    function refreshCurrentPage() {
        if (currentPageData) {
            showJSON(currentPageData.model);
            showGeneratedPage(generatePage(currentPageData.model, false), currentPageData.status);
        }
    }

    function tryRestorePageFromHistory(state) {
        if (state) {
            currentPageData = state;
            refreshCurrentPage();
        } else {
            // Assume that this is the initial page and just reload it to start over. This ensures that a new instance
            // of the "api fetch" is created (discard the session).
            window.location.reload();
        }
    }

    function deepCopy(object) {
        return JSON.parse(JSON.stringify(object));
    }

    /** VIEWS **/

    /**
     * Default component views to render the different UI elements.
     */
    const defaultViews = {

        ButtonForLink: function (link) {
            const openExternal = link.rel === 'launch';
            return views.Button({
                name: link.rel,
                label: link.title || `link:${link.rel}`,
                onClick: () => openExternal ? window.open(link.href, '_blank') : apiRequest(link.href)
            });
        },

        ImageLink: function (link) {
            let img = new Image();
            img.src = link.href;
            img.alt = link.title || link.rel;
            let component = document.createElement('div')
            if (link.title) {
                let componentTitle = document.createElement('h3')
                componentTitle.textContent = link.title;
                component.append(componentTitle);
            }
            component.append(img)
            return component;
        },

        Redirect: function (action, hideTitle) {
            if (!action.title) {
                action.title = 'API redirect, should be followed automatically by the client';
            }
            let fieldTypes = (action.model.fields || []).map(field => field.type);
            if (!fieldTypes.every(type => type === 'hidden')) {
                console.warn("Not all redirect form fields are hidden, this likely makes this form impossible " +
                    "to auto-submit, so it should not be a redirect form");
            }
            return views.ActionForm(action, hideTitle)
        },

        Selector: function (action, hideTitle) {

            const parentElement = document.createElement('div');
            parentElement.classList.add('siimple-form');

            if (!hideTitle) {
                const titleElement = document.createElement('div');
                titleElement.textContent = action.title;
                titleElement.classList.add('siimple-form-title');
                parentElement.append(titleElement);
            }

            const optionsElement = document.createElement('div');
            generateActions({actions: action.model.options})
                .forEach(e => optionsElement.append(e));

            parentElement.append(optionsElement);
            return parentElement;
        },

        ActionForm: function (action, hideTitle) {
            const formElement = document.createElement('div');
            formElement.classList.add('siimple-form');

            if (!hideTitle) {
                const title = document.createElement('div');
                title.textContent = action.title;
                if (title.textContent) {
                    title.classList.add('siimple-form-title');
                    formElement.append(title);
                }
            }

            const fieldsElement = document.createElement('div');

            const fields = action.model.fields || [];
            const fieldViewModels = fields.map(field => {
                const fieldRoot = document.createElement('div');
                fieldRoot.classList.add('siimple-field');

                const label = document.createElement('label');
                label.className = `siimple-label${field.type === 'hidden' ? ' disabled ' : ''}`;
                label.innerText = field.label || field.name;

                const error = document.createElement('div');
                error.className = 'siimple-field-helper siimple--color-error';

                let type = field.type || 'text';
                // this is a demo app: show everything
                if (type === 'hidden' || type === 'username') {
                    type = 'text';
                }

                let input;
                if (type === 'select') {
                    input = document.createElement('select');
                    input.className = 'siimple-select siimple-select--fluid';
                    input.name = field.name;
                    (field.options || []).forEach(({value, label}) => {
                        const option = document.createElement('option');
                        option.value = value;
                        option.innerText = label;
                        input.append(option);
                    });
                } else {
                    input = document.createElement('input');
                    input.className = 'siimple-input siimple-input--fluid';
                    input.type = type;
                    input.name = field.name;
                    input.value = field.value || '';
                    input.placeholder = field.placeholder || '';
                    input.checked = field.checked;
                    input.disabled = field.readonly;
                }

                fieldRoot.append(label);
                fieldRoot.append(input);
                fieldRoot.append(error);

                // keep track of the value on the model itself
                input.oninput = (event) => field.value = event.target.value;
                if (input.type === 'checkbox') {
                    input.onchange = (event) => field.checked = event.target.checked;
                }

                return {
                    model: field,
                    view: fieldRoot,
                    onError: function (message) {
                        label.classList.add('siimple--color-error');
                        input.classList.add('error');
                        error.innerText = message;
                    },
                    clearError: function () {
                        label.classList.remove('siimple--color-error');
                        input.classList.remove('error');
                        error.innerText = '';
                    }
                };
            });
            fieldViewModels.forEach(vm => fieldsElement.append(vm.view));

            // function that well be invoked when the current form action results in an 'invalid input' error
            const onInvalidInput = function (invalidFields) {
                fieldViewModels.forEach(vm => vm.clearError());
                invalidFields.forEach(({name, detail}) => {
                    const fieldVM = fieldViewModels.find(vm => vm.model.name === name);
                    if (fieldVM) {
                        fieldVM.onError(detail);
                    }
                });
            };

            const submitButton = views.Button({
                name: action.kind,
                label: action.model.actionTitle || 'Submit',
                color: action.kind === 'cancel' ? 'warning' : 'success',
                onClick: () => apiRequestForFormAction(action, onInvalidInput),
            });
            fieldsElement.append(submitButton);

            formElement.append(fieldsElement);
            return formElement;
        },

        Polling: function (apiResponsePayload, autoFollowLinks) {
            let components = generateActions(apiResponsePayload, autoFollowLinks);
            const pollingStatus = apiResponsePayload.properties.status;
            const mainElement = document.createElement('div');
            const statusElement = document.createElement('div');
            const alertType = pollingStatus === 'failed'
                ? 'error'
                : pollingStatus === 'done'
                    ? 'success'
                    : 'primary';
            statusElement.classList.add("siimple-alert", "siimple-alert--" + alertType);
            statusElement.textContent = `Polling status: ${pollingStatus}`;
            mainElement.append(statusElement);
            components.push(mainElement);
            return components;
        },

        LaunchUrl: function (href, action, autoFollowLinks) {
            const root = document.createElement('div');

            root.append(views.Button({
                label: action.title || 'Launch', big: true, onClick: () => {
                    // launch, then replace the whole screen with the "continueActions"
                    // (TODO errorActions should never be followed as window.open doesn't fail?)
                    window.open(href, '_self');
                    continueToNestedActions(action, autoFollowLinks);
                }
            }));

            return root;
        },

        Foldable: function (title, actionElement) {
            let root = document.createElement('details');
            let summary = document.createElement('summary');
            summary.innerText = title;
            root.append(summary);
            let container = document.createElement('div');
            container.classList.add('details-container');
            container.append(actionElement)
            root.append(container);
            return root;
        },

        Button: function ({label, onClick, color, disabled, big, name, id}) {
            const button = document.createElement('div');
            if (id) {
                button.id = id
            }
            button.classList.add('siimple--mb-4', 'siimple-btn', `siimple-btn--${color || 'blue'}`, name);
            if (big) {
                button.classList.add('siimple-btn--big');
            }
            button.textContent = label || '';
            if (onClick) {
                button.onclick = (e) => {
                    if (button.classList.contains('siimple-btn--disabled')) {
                        console.log('Button click handler not called because button is disabled');
                    } else {
                        onClick(e);
                    }
                };
            }
            if (disabled) {
                button.classList.add('siimple-btn--disabled');
            }
            return button;
        },

        ErrorMessage: function (message) {
            const errorElement = document.createElement('div');
            errorElement.classList.add("siimple-tip", "siimple-tip--error");
            errorElement.id = 'error-message-id'
            errorElement.textContent = message;
            return errorElement;
        },

        Spinner: function () {
            const rootElement = document.createElement('div');
            rootElement.classList.add('siimple-spinner', 'siimple-spinner--success');
            return rootElement;
        },

        Ruler: function () {
            const rootElement = document.createElement('div');
            rootElement.classList.add('siimple-rule');
            return rootElement;
        },

        Message: function (message) {
            const color = {
                warn: 'warning',
                info: 'primary',
            }[message.classList[0]] || message.classList[0];

            const rootElement = document.createElement('div');
            rootElement.classList.add('siimple-alert', `siimple-alert--${color}`)
            rootElement.textContent = message.text;
            return rootElement;
        }
    };

    /**
     * Replace some component views by others that take into account more details of the API representations, such as
     * specific action 'kind' values.
     *
     * This illustrates how a client application could take into account more details of the API representations (such
     * as specific action 'kind' values) and provide a richer UX.
     */
    const enhancedViews = {
        ...defaultViews,

        Selector: function (action, hideTitle) {

            // Improved UI if we know this kind of selector
            if (action.kind === 'authenticator-selector') {
                return this.Authenticator_Selector(action, hideTitle);
            }

            // Otherwise, use the default view
            return defaultViews.Selector(action, hideTitle);
        },

        Authenticator_Selector: function (action, hideTitle) {
            const parentElement = document.createElement('div');
            parentElement.classList.add('siimple-form');

            if (!hideTitle) {
                const titleElement = document.createElement('div');
                titleElement.textContent = action.title;
                titleElement.classList.add('siimple-form-title');
                parentElement.append(titleElement);
            }

            const optionsElement = document.createElement('div');

            action.model.options.forEach(option => {
                const optionElement = document.createElement('div');
                optionElement.classList.add('siimple-alert',
                    option.properties && option.properties.authenticatorType === 'html-form' ? 'siimple-alert--success' : 'siimple-alert--primary');
                const linkElement = document.createElement('a');
                linkElement.href = '#';
                linkElement.id = option.title.replace(/\s/g, '_')
                linkElement.onclick = function (e) {
                    e.preventDefault();
                    apiRequestForFormAction(option);
                };
                linkElement.textContent = option.title;
                optionElement.append(linkElement);
                optionsElement.append(optionElement);
            });

            parentElement.append(optionsElement);
            return parentElement;
        }
    }

    let views = enhancedViews; // Enhanced views by default

    spinnerElement.append(views.Spinner());
}
