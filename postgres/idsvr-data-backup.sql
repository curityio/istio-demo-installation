--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2 (Debian 13.2-1.pgdg100+1)
-- Dumped by pg_dump version 13.2 (Debian 13.2-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    account_id character varying(64) DEFAULT public.uuid_generate_v1() NOT NULL,
    username character varying(64) NOT NULL,
    password character varying(128),
    email character varying(64),
    phone character varying(32),
    attributes jsonb,
    active smallint DEFAULT 0 NOT NULL,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: COLUMN accounts.account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.account_id IS 'Account id, or username, of this account. Unique.';


--
-- Name: COLUMN accounts.password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.password IS 'The hashed password. Optional';


--
-- Name: COLUMN accounts.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.email IS 'The associated email address. Optional';


--
-- Name: COLUMN accounts.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.phone IS 'The phone number of the account owner. Optional';


--
-- Name: COLUMN accounts.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.attributes IS 'Key/value map of additional attributes associated with the account.';


--
-- Name: COLUMN accounts.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.active IS 'Indicates if this account has been activated or not. Activation is usually via email or sms.';


--
-- Name: COLUMN accounts.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.created IS 'Time since epoch of account creation, in seconds';


--
-- Name: COLUMN accounts.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.updated IS 'Time since epoch of latest account update, in seconds';


--
-- Name: audit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit (
    id character varying(64) NOT NULL,
    instant timestamp without time zone NOT NULL,
    event_instant character varying(64) NOT NULL,
    server character varying(255) NOT NULL,
    message text NOT NULL,
    event_type character varying(48) NOT NULL,
    subject character varying(128),
    client character varying(128),
    resource character varying(128),
    authenticated_subject character varying(128),
    authenticated_client character varying(128),
    acr character varying(128),
    endpoint character varying(255),
    session character varying(128)
);


ALTER TABLE public.audit OWNER TO postgres;

--
-- Name: COLUMN audit.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.id IS 'Unique ID of the log message';


--
-- Name: COLUMN audit.instant; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.instant IS 'Moment that the event was logged';


--
-- Name: COLUMN audit.event_instant; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.event_instant IS 'Moment that the event occurred';


--
-- Name: COLUMN audit.server; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.server IS 'The server node where the event occurred';


--
-- Name: COLUMN audit.message; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.message IS 'Message describing the event';


--
-- Name: COLUMN audit.event_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.event_type IS 'Type of event that the message is about';


--
-- Name: COLUMN audit.subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.subject IS 'The subject (i.e., user) effected by the event';


--
-- Name: COLUMN audit.client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.client IS 'The client ID effected by the event';


--
-- Name: COLUMN audit.resource; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.resource IS 'The resource ID effected by the event';


--
-- Name: COLUMN audit.authenticated_subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.authenticated_subject IS 'The authenticated subject (i.e., user) effected by the event';


--
-- Name: COLUMN audit.authenticated_client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.authenticated_client IS 'The authenticated client effected by the event';


--
-- Name: COLUMN audit.acr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.acr IS 'The ACR used to authenticate the subject (i.e., user)';


--
-- Name: COLUMN audit.endpoint; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.endpoint IS 'The endpoint where the event was triggered';


--
-- Name: COLUMN audit.session; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.session IS 'The session ID in which the event was triggered';


--
-- Name: buckets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.buckets (
    subject character varying(128) NOT NULL,
    purpose character varying(64) NOT NULL,
    attributes jsonb NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


ALTER TABLE public.buckets OWNER TO postgres;

--
-- Name: COLUMN buckets.subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.subject IS 'The subject that together with the purpose identify this bucket';


--
-- Name: COLUMN buckets.purpose; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.purpose IS 'The purpose of this bucket, eg. "login_attempt_counter"';


--
-- Name: COLUMN buckets.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.attributes IS 'All attributes stored for this subject/purpose';


--
-- Name: COLUMN buckets.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.created IS 'When this bucket was created';


--
-- Name: COLUMN buckets.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.updated IS 'When this bucket was last updated';


--
-- Name: delegations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delegations (
    id character varying(40) NOT NULL,
    owner character varying(128) NOT NULL,
    created bigint NOT NULL,
    expires bigint NOT NULL,
    scope character varying(1000),
    scope_claims text,
    client_id character varying(128) NOT NULL,
    redirect_uri character varying(512),
    status character varying(16) NOT NULL,
    claims text,
    authentication_attributes text,
    authorization_code_hash character varying(89)
);


ALTER TABLE public.delegations OWNER TO postgres;

--
-- Name: COLUMN delegations.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.id IS 'Unique identifier';


--
-- Name: COLUMN delegations.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.owner IS 'Moment when delegations record is created, as measured in number of seconds since epoch';


--
-- Name: COLUMN delegations.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.expires IS 'Moment when delegation expires, as measured in number of seconds since epoch';


--
-- Name: COLUMN delegations.scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.scope IS 'Space delimited list of scope values';


--
-- Name: COLUMN delegations.scope_claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.scope_claims IS 'JSON with the scope-claims configuration at the time of delegation issuance';


--
-- Name: COLUMN delegations.client_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.client_id IS 'Reference to a client; non-enforced';


--
-- Name: COLUMN delegations.redirect_uri; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.redirect_uri IS 'Optional value for the redirect_uri parameter, when provided in a request for delegation';


--
-- Name: COLUMN delegations.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.status IS 'Status of the delegation instance, from {''issued'', ''revoked''}';


--
-- Name: COLUMN delegations.claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.claims IS 'Optional JSON that contains a list of claims that are part of the delegation';


--
-- Name: COLUMN delegations.authentication_attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.authentication_attributes IS 'The JSON-serialized AuthenticationAttributes established for this delegation';


--
-- Name: COLUMN delegations.authorization_code_hash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.authorization_code_hash IS 'A hash of the authorization code that was provided when this delegation was issued.';


--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id character varying(64) NOT NULL,
    device_id character varying(64),
    account_id character varying(256),
    external_id character varying(32),
    alias character varying(30),
    form_factor character varying(10),
    device_type character varying(50),
    owner character varying(256),
    attributes jsonb,
    expires bigint,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: COLUMN devices.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.id IS 'Unique ID of the device';


--
-- Name: COLUMN devices.device_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.device_id IS 'The device ID that identifies the physical device';


--
-- Name: COLUMN devices.account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.account_id IS 'The user account ID that is associated with the device';


--
-- Name: COLUMN devices.external_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.external_id IS 'The phone or other identifying number of the device (if it has one)';


--
-- Name: COLUMN devices.alias; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.alias IS 'The user-recognizable name or mnemonic identifier of the device (e.g., my work iPhone)';


--
-- Name: COLUMN devices.form_factor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.form_factor IS 'The type or form of device (e.g., laptop, phone, tablet, etc.)';


--
-- Name: COLUMN devices.device_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.device_type IS 'The device type (i.e., make, manufacturer, provider, class)';


--
-- Name: COLUMN devices.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.owner IS 'The owner of the device. This is the user who has administrative rights on the device';


--
-- Name: COLUMN devices.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.attributes IS 'Key/value map of custom attributes associated with the device.';


--
-- Name: COLUMN devices.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.expires IS 'Time since epoch of device expiration, in seconds';


--
-- Name: COLUMN devices.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.created IS 'Time since epoch of device creation, in seconds';


--
-- Name: COLUMN devices.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.updated IS 'Time since epoch of latest device update, in seconds';


--
-- Name: dynamically_registered_clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dynamically_registered_clients (
    client_id character varying(64) NOT NULL,
    client_secret character varying(128),
    instance_of_client character varying(64),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    initial_client character varying(64),
    authenticated_user character varying(64),
    attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    status character varying(12) DEFAULT 'active'::character varying NOT NULL,
    scope text,
    redirect_uris text,
    grant_types character varying(128)
);


ALTER TABLE public.dynamically_registered_clients OWNER TO postgres;

--
-- Name: COLUMN dynamically_registered_clients.client_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.client_id IS 'The client ID of this client instance';


--
-- Name: COLUMN dynamically_registered_clients.client_secret; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.client_secret IS 'The hash of this client''s secret';


--
-- Name: COLUMN dynamically_registered_clients.instance_of_client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.instance_of_client IS 'The client ID on which this instance is based, or NULL if this is a non-templatized client';


--
-- Name: COLUMN dynamically_registered_clients.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.created IS 'When this client was originally created (in UTC time)';


--
-- Name: COLUMN dynamically_registered_clients.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.updated IS 'When this client was last updated (in UTC time)';


--
-- Name: COLUMN dynamically_registered_clients.initial_client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.initial_client IS 'In case the user authenticated, this value contains a client_id value of the initial token. If the initial token was issued through a client credentials-flow, the initial_client value is set to the client that authenticated. Registration without initial token (i.e. with no authentication) will result in a null value for initial_client';


--
-- Name: COLUMN dynamically_registered_clients.authenticated_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.authenticated_user IS 'In case a user authenticated (through a client), this value contains the sub value of the initial token';


--
-- Name: COLUMN dynamically_registered_clients.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.attributes IS 'Arbitrary attributes tied to this client';


--
-- Name: COLUMN dynamically_registered_clients.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.status IS 'The current status of the client, allowed values are "active", "inactive" and "revoked"';


--
-- Name: COLUMN dynamically_registered_clients.scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.scope IS 'Space separated list of scopes defined for this client (non-templatized clients only)';


--
-- Name: COLUMN dynamically_registered_clients.redirect_uris; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.redirect_uris IS 'Space separated list of redirect URI''s defined for this client (non-templatized clients only)';


--
-- Name: COLUMN dynamically_registered_clients.grant_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.grant_types IS 'Space separated list of grant types defined for this client (non-templatized clients only)';


--
-- Name: linked_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linked_accounts (
    account_id character varying(64),
    linked_account_id character varying(64) NOT NULL,
    linked_account_domain_name character varying(64) NOT NULL,
    linking_account_manager character varying(128),
    created timestamp without time zone NOT NULL
);


ALTER TABLE public.linked_accounts OWNER TO postgres;

--
-- Name: COLUMN linked_accounts.account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.linked_accounts.account_id IS 'Account ID, typically a global one, of the account being linked from (the linker)';


--
-- Name: COLUMN linked_accounts.linked_account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.linked_accounts.linked_account_id IS 'Account ID, typically a local or legacy one, of the account being linked (the linkee)';


--
-- Name: COLUMN linked_accounts.linked_account_domain_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.linked_accounts.linked_account_domain_name IS 'The domain (i.e., organizational group or realm) of the account being linked';


--
-- Name: nonces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nonces (
    token character varying(64) NOT NULL,
    reference_data text NOT NULL,
    created bigint NOT NULL,
    ttl bigint NOT NULL,
    consumed bigint,
    status character varying(16) DEFAULT 'issued'::character varying NOT NULL
);


ALTER TABLE public.nonces OWNER TO postgres;

--
-- Name: COLUMN nonces.token; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.token IS 'Value issued as random nonce';


--
-- Name: COLUMN nonces.reference_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.reference_data IS 'Value that is referenced by the nonce value';


--
-- Name: COLUMN nonces.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.created IS 'Moment when nonce record is created, as measured in number of seconds since epoch';


--
-- Name: COLUMN nonces.ttl; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.ttl IS 'Time To Live, period in seconds since created after which the nonce expires';


--
-- Name: COLUMN nonces.consumed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.consumed IS 'Moment when nonce was consumed, as measured in number of seconds since epoch';


--
-- Name: COLUMN nonces.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.status IS 'Status of the nonce from {''issued'', ''revoked'', ''used''}';


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id character varying(64) NOT NULL,
    session_data text NOT NULL,
    expires bigint NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: COLUMN sessions.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sessions.id IS 'id given to the session';


--
-- Name: COLUMN sessions.session_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sessions.session_data IS 'Value that is referenced by the session id';


--
-- Name: COLUMN sessions.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sessions.expires IS 'Moment when session record expires, as measured in number of seconds since epoch';


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
    token_hash character varying(89) NOT NULL,
    id character varying(64),
    delegations_id character varying(40) NOT NULL,
    purpose character varying(32) NOT NULL,
    usage character varying(8) NOT NULL,
    format character varying(32) NOT NULL,
    created bigint NOT NULL,
    expires bigint NOT NULL,
    scope character varying(1000),
    scope_claims text,
    status character varying(16) NOT NULL,
    issuer character varying(200) NOT NULL,
    subject character varying(64) NOT NULL,
    audience character varying(512),
    not_before bigint,
    claims text,
    meta_data text
);


ALTER TABLE public.tokens OWNER TO postgres;

--
-- Name: COLUMN tokens.token_hash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.token_hash IS 'Base64 encoded sha-512 hash of the token value.';


--
-- Name: COLUMN tokens.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.id IS 'Identifier of the token, when it exists; this can be the value from the ''jti''-claim of a JWT, etc. Opaque tokens do not have an id.';


--
-- Name: COLUMN tokens.delegations_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.delegations_id IS 'Reference to the delegation instance that underlies the token';


--
-- Name: COLUMN tokens.purpose; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.purpose IS 'Purpose of the token, i.e. ''nonce'', ''accesstoken'', ''refreshtoken'', ''custom'', etc.';


--
-- Name: COLUMN tokens.usage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.usage IS 'Indication whether the token is a bearer or proof token, from {"bearer", "proof"}';


--
-- Name: COLUMN tokens.format; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.format IS 'The format of the token, i.e. ''opaque'', ''jwt'', etc.';


--
-- Name: COLUMN tokens.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.created IS 'Moment when token record is created, as measured in number of seconds since epoch';


--
-- Name: COLUMN tokens.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.expires IS 'Moment when token expires, as measured in number of seconds since epoch';


--
-- Name: COLUMN tokens.scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.scope IS 'Space delimited list of scope values';


--
-- Name: COLUMN tokens.scope_claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.scope_claims IS 'Space delimited list of scope-claims values';


--
-- Name: COLUMN tokens.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.status IS 'Status of the token from {''issued'', ''used'', ''revoked''}';


--
-- Name: COLUMN tokens.issuer; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.issuer IS 'Optional name of the issuer of the token (jwt.iss)';


--
-- Name: COLUMN tokens.subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.subject IS 'Optional subject of the token (jwt.sub)';


--
-- Name: COLUMN tokens.audience; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.audience IS 'Space separated list of audiences for the token (jwt.aud)';


--
-- Name: COLUMN tokens.not_before; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.not_before IS 'Moment before which the token is not valid, as measured in number of seconds since epoch (jwt.nbf)';


--
-- Name: COLUMN tokens.claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.claims IS 'Optional JSON-blob that contains a list of claims that are part of the token';


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (account_id, username, password, email, phone, attributes, active, created, updated) FROM stdin;
5cdab730-ad87-11eb-b96f-0242ac110008	john.doe	$5$rounds=20000$lSlVng9ZCQyTL5e1$D9Fg9mA1UGhKNKyh99C/eqpHsa1afjMzi/8Od4xnp2.	john.doe@curity.local	\N	{"name": {"givenName": "John", "familyName": "Doe"}, "emails": [{"value": "john.doe@curity.local", "primary": true}], "agreeToTerms": "on", "urn:se:curity:scim:2.0:Devices": []}	1	1620208245	1620208245
\.


--
-- Data for Name: audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit (id, instant, event_instant, server, message, event_type, subject, client, resource, authenticated_subject, authenticated_client, acr, endpoint, session) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.buckets (subject, purpose, attributes, created, updated) FROM stdin;
\.


--
-- Data for Name: delegations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegations (id, owner, created, expires, scope, scope_claims, client_id, redirect_uri, status, claims, authentication_attributes, authorization_code_hash) FROM stdin;
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, device_id, account_id, external_id, alias, form_factor, device_type, owner, attributes, expires, created, updated) FROM stdin;
\.


--
-- Data for Name: dynamically_registered_clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dynamically_registered_clients (client_id, client_secret, instance_of_client, created, updated, initial_client, authenticated_user, attributes, status, scope, redirect_uris, grant_types) FROM stdin;
\.


--
-- Data for Name: linked_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.linked_accounts (account_id, linked_account_id, linked_account_domain_name, linking_account_manager, created) FROM stdin;
\.


--
-- Data for Name: nonces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nonces (token, reference_data, created, ttl, consumed, status) FROM stdin;
aPWDZg1ldVi4wOZjraYWyxYyZtBsmKOg	eyJfX21hbmRhdG9yeV9fIjp7ImV4cGlyZXMiOjE2MjAyMDg1NDgsImNyZWF0ZWQiOjE2MjAyMDgyNDgsInB1cnBvc2UiOiJsb2dpbl90b2tlbiJ9LCJfX3Rva2VuX2NsYXNzX25hbWVfXyI6InNlLmN1cml0eS5pZGVudGl0eXNlcnZlci50b2tlbnMuZGF0YS5Ob25jZURhdGEiLCJfX29wdGlvbmFsX18iOnsiaXNzIjoiYXV0aGVudGljYXRpb24tc2VydmljZSIsImNvbnRleHQiOnsiYXV0aF90aW1lIjoxNjIwMjA4MjQ4LCJhY3IiOiJ1cm46c2U6Y3VyaXR5OmF1dGhlbnRpY2F0aW9uOmh0bWwtZm9ybTpVc2VybmFtZVBhc3N3b3JkIiwiYXV0aGVudGljYXRpb25TZXNzaW9uRGF0YSI6eyJzZXJ2aWNlUHJvdmlkZXJQcm9maWxlSWQiOiJ0b2tlbi1zZXJ2aWNlIiwic2VydmljZVByb3ZpZGVySWQiOiJoYWFwaS13ZWItY2xpZW50Iiwic2lkIjoiWjRMaTcxckI0WmZySFJYUiJ9fSwiYXVkIjoidG9rZW4tc2VydmljZSIsInNlc3Npb25JZCI6IjIxMDA0ODJlLWNjMTgtNGFmOC1hNTdjLWEzYjcwYzIxMjMxOCIsInN1YmplY3QiOnsiYWNjb3VudElkIjoiNWNkYWI3MzAtYWQ4Ny0xMWViLWI5NmYtMDI0MmFjMTEwMDA4IiwidXNlck5hbWUiOiJqb2huLmRvZSIsInN1YmplY3QiOiJqb2huLmRvZSJ9fX0=	1620208248	300	1620208249	used
Zpwbkp4un7TKcu0HHADJPc15J2woASrF	eyJfX21hbmRhdG9yeV9fIjp7ImV4cGlyZXMiOjE2MjAyMDgyNzksImNyZWF0ZWQiOjE2MjAyMDgyNDksInB1cnBvc2UiOiJub25jZSJ9LCJfX3Rva2VuX2NsYXNzX25hbWVfXyI6InNlLmN1cml0eS5pZGVudGl0eXNlcnZlci50b2tlbnMuZGF0YS5Ob25jZURhdGEiLCJfX29wdGlvbmFsX18iOnsicmVkaXJlY3RVcmkiOiJodHRwczovL2xvY2FsaG9zdDo3Nzc3L2NhbGxiYWNrIiwib3duZXIiOiI2MmZkNmMwZjUyZWZkYzgzNzRkOGU2NmVmZjhjZTQxMjJmZGRiZWYwNGEwMWFjNGFkMGJlMzE5NTdiNDJlYTVjIiwiYXVkaWVuY2UiOiJoYWFwaS13ZWItY2xpZW50IiwicmVkaXJlY3RVcmlQcm92aWRlZCI6dHJ1ZSwiY2xpZW50SWQiOiJoYWFwaS13ZWItY2xpZW50IiwiYXV0aGVudGljYXRpb25BdHRyaWJ1dGVzIjp7InN1YmplY3QiOnsiYWNjb3VudElkIjoiNWNkYWI3MzAtYWQ4Ny0xMWViLWI5NmYtMDI0MmFjMTEwMDA4IiwidXNlck5hbWUiOiJqb2huLmRvZSIsInN1YmplY3QiOiJqb2huLmRvZSJ9LCJjb250ZXh0Ijp7ImF1dGhfdGltZSI6MTYyMDIwODI0OCwiYWNyIjoidXJuOnNlOmN1cml0eTphdXRoZW50aWNhdGlvbjpodG1sLWZvcm06VXNlcm5hbWVQYXNzd29yZCIsImF1dGhlbnRpY2F0aW9uU2Vzc2lvbkRhdGEiOnsic2VydmljZVByb3ZpZGVyUHJvZmlsZUlkIjoidG9rZW4tc2VydmljZSIsInNlcnZpY2VQcm92aWRlcklkIjoiaGFhcGktd2ViLWNsaWVudCIsInNpZCI6Ilo0TGk3MXJCNFpmckhSWFIifX19LCJzY29wZSI6InJlYWQiLCJjbGFpbXMiOnsidW5tYXBwZWRDbGFpbXMiOnsiaXNzIjp7InJlcXVpcmVkIjp0cnVlfSwic3ViIjp7InJlcXVpcmVkIjp0cnVlfSwiYXVkIjp7InJlcXVpcmVkIjp0cnVlfSwiZXhwIjp7InJlcXVpcmVkIjp0cnVlfSwiaWF0Ijp7InJlcXVpcmVkIjp0cnVlfSwiYXV0aF90aW1lIjp7InJlcXVpcmVkIjp0cnVlfSwibm9uY2UiOnsicmVxdWlyZWQiOnRydWV9LCJhY3IiOnsicmVxdWlyZWQiOnRydWV9LCJhbXIiOnsicmVxdWlyZWQiOnRydWV9LCJhenAiOnsicmVxdWlyZWQiOnRydWV9LCJuYmYiOnsicmVxdWlyZWQiOnRydWV9LCJjbGllbnRfaWQiOnsicmVxdWlyZWQiOnRydWV9LCJkZWxlZ2F0aW9uX2lkIjp7InJlcXVpcmVkIjp0cnVlfSwicHVycG9zZSI6eyJyZXF1aXJlZCI6dHJ1ZX0sInNjb3BlIjp7InJlcXVpcmVkIjp0cnVlfSwianRpIjp7InJlcXVpcmVkIjp0cnVlfSwic2lkIjp7InJlcXVpcmVkIjp0cnVlfX19LCJzdGF0ZSI6ImZvbyIsInNpZCI6Ilo0TGk3MXJCNFpmckhSWFIifX0=	1620208249	30	\N	issued
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, session_data, expires) FROM stdin;
04f7964f-94f5-48b4-a943-131e29ad9304	rO0ABXNyADVjb20uZ29vZ2xlLmNvbW1vbi5jb2xsZWN0LkltbXV0YWJsZU1hcCRTZXJpYWxpemVkRm9ybQAAAAAAAAAAAgACTAAEa2V5c3QAEkxqYXZhL2xhbmcvT2JqZWN0O0wABnZhbHVlc3EAfgABeHB1cgATW0xqYXZhLmxhbmcuT2JqZWN0O5DOWJ8QcylsAgAAeHAAAAALdAAeX2F1dGhuLXJlcS5zZXJ2aWNlLXByb3ZpZGVyLWlkdAAZQVVUSE5fSU5URVJNRURJQVRFX1JFU1VMVHQAEVJFU1VNQUJMRV9SRVFVRVNUdAAOX19hdXRoblJlcXVlc3R0AB1wcm90b2NvbFJlcXVlc3RUcmFuc2Zvcm1lcjppZHQAIVNUQVJUX0FVVEhOX1RJTUVfQVNfRVBPQ0hfU0VDT05EU3QAG29yaWdpbmFsLWF1dGh6LXF1ZXJ5LXN0cmluZ3QAGVVzZXJuYW1lUGFzc3dvcmQuYXR0ZW1wdHN0ABtvcmlnaW5hbC1hdXRobi1xdWVyeS1zdHJpbmd0AA1oYWFwaS1hYXQta2V5dAAOX3RyYW5zYWN0aW9uSWR1cQB+AAMAAAALc3IAPHNlLmN1cml0eS5pZGVudGl0eXNlcnZlci5zZXNzaW9uLkludGVybmFsU2Vzc2lvbiRTZXNzaW9uRGF0YWv83TpNympcAgABTAAGX3ZhbHVldAApTGNvbS9nb29nbGUvY29tbW9uL2NvbGxlY3QvSW1tdXRhYmxlTGlzdDt4cHNyADZjb20uZ29vZ2xlLmNvbW1vbi5jb2xsZWN0LkltbXV0YWJsZUxpc3QkU2VyaWFsaXplZEZvcm0AAAAAAAAAAAIAAVsACGVsZW1lbnRzdAATW0xqYXZhL2xhbmcvT2JqZWN0O3hwdXEAfgADAAAAAXNyAE1zZS5jdXJpdHkuaWRlbnRpdHlzZXJ2ZXIucGx1Z2luLnByb3RvY29sLnNpbXBsZWFwaS5TaW1wbGVBcGlTZXJ2aWNlUHJvdmlkZXJJZLeeWtuK5hgeAgACWgAXX2lzT0F1dGhTZXJ2aWNlUHJvdmlkZXJMAAlfY2xpZW50SWR0ADVMc2UvY3VyaXR5L2lkZW50aXR5c2VydmVyL2RhdGEvZG9tYWluL29hdXRoL0NsaWVudElkO3hyADxzZS5jdXJpdHkuaWRlbnRpdHlzZXJ2ZXIucGx1Z2lucy5wcm90b2NvbHMuU2VydmljZVByb3ZpZGVySWSwqiR2IDCVcgIAAkwACl9wcm9maWxlSWR0ABJMamF2YS9sYW5nL1N0cmluZztMAAZfdmFsdWVxAH4AG3hwdAANdG9rZW4tc2VydmljZXQAEGhhYXBpLXdlYi1jbGllbnQBc3IAM3NlLmN1cml0eS5pZGVudGl0eXNlcnZlci5kYXRhLmRvbWFpbi5vYXV0aC5DbGllbnRJZOl3K4MOWnwfAgADWgAGX3ZhbGlkTAAJX2NsaWVudElkcQB+ABtMABBfZXN0YWJsaXNoZWRGcm9tdAATTGphdmEvdXRpbC9FbnVtU2V0O3hwAXEAfgAec3IAJGphdmEudXRpbC5FbnVtU2V0JFNlcmlhbGl6YXRpb25Qcm94eQUH09t2VMrRAgACTAALZWxlbWVudFR5cGV0ABFMamF2YS9sYW5nL0NsYXNzO1sACGVsZW1lbnRzdAARW0xqYXZhL2xhbmcvRW51bTt4cHZyAENzZS5jdXJpdHkuaWRlbnRpdHlzZXJ2ZXIuZGF0YS5kb21haW4ub2F1dGguQ2xpZW50SWQkRXN0YWJsaXNoZWRGcm9tAAAAAAAAAAASAAB4cgAOamF2YS5sYW5nLkVudW0AAAAAAAAAABIAAHhwdXIAEVtMamF2YS5sYW5nLkVudW07qI3qLTPSL5gCAAB4cAAAAAF+cQB+ACZ0AAxRVUVSWV9TVFJJTkdzcQB+ABFzcQB+ABR1cQB+AAMAAAAAc3EAfgARc3EAfgAUdXEAfgADAAAAAXQA4nsidmVyaWZpZXIiOiJSX01lY3RRa3puRG1YYUp1WUlDcGljUXR1S2Q4Q2tNR2lxIiwidmFsdWUiOiJjbGllbnRfaWRcdTAwM2RoYWFwaS13ZWItY2xpZW50XHUwMDI2cmVkaXJlY3RfdXJpXHUwMDNkaHR0cHMlM0ElMkYlMkZsb2NhbGhvc3QlM0E3Nzc3JTJGY2FsbGJhY2tcdTAwMjZyZXNwb25zZV90eXBlXHUwMDNkY29kZVx1MDAyNnNjb3BlXHUwMDNkcmVhZFx1MDAyNnN0YXRlXHUwMDNkZm9vIn1zcQB+ABFzcQB+ABR1cQB+AAMAAAABc3IAPXNlLmN1cml0eS5pZGVudGl0eXNlcnZlci5hdXRoZW50aWNhdGlvbi5BdXRoZW50aWNhdGlvblJlcXVlc3Q+xz58xwhrswIADVoAFF9mb3JjZUF1dGhlbnRpY2F0aW9uWgATX29hdXRoQXV0aG9yaXphdGlvbkwAD19hcHBsaWNhdGlvblVybHEAfgAbTAAVX2F1dGhlbnRpY2F0b3JGaWx0ZXJzdAAoTGNvbS9nb29nbGUvY29tbW9uL2NvbGxlY3QvSW1tdXRhYmxlU2V0O0wACl9mcmVzaG5lc3N0ABBMamF2YS9sYW5nL0xvbmc7TAAWX29yaWdpbmFsUmVxdWVzdE1ldGhvZHEAfgAbTAAaX29yaWdpbmFsUmVxdWVzdFBhcmFtZXRlcnN0AC1MY29tL2dvb2dsZS9jb21tb24vY29sbGVjdC9JbW11dGFibGVNdWx0aW1hcDtMABJfcmVxdWVzdEZpbHRlckFjcnN0AA9MamF2YS91dGlsL1NldDtMABFfcmVzcG9uc2VBdWRpZW5jZXEAfgAbTAALX3Jlc3VtZVBhdGhxAH4AG0wAD19zc29SZXF1aXJlbWVudHQAOExzZS9jdXJpdHkvaWRlbnRpdHlzZXJ2ZXIvYXV0aGVudGljYXRpb24vU3NvUmVxdWlyZW1lbnQ7TAAGX3N0YXRlcQB+ABtMAA1fdGVtcGxhdGVBcmVhcQB+ABt4cgA+c2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLmF1dGhlbnRpY2F0aW9uLlNlcnZpY2VQcm92aWRlclJlcXVlc3Qyc6RcVXzCZgIAAkQAG19zZXJpYWxpemF0aW9uRm9ybWF0VmVyc2lvbkwAEl9zZXJ2aWNlUHJvdmlkZXJJZHQAPkxzZS9jdXJpdHkvaWRlbnRpdHlzZXJ2ZXIvcGx1Z2lucy9wcm90b2NvbHMvU2VydmljZVByb3ZpZGVySWQ7eHIAN3NlLmN1cml0eS5pZGVudGl0eXNlcnZlci5hdXRoZW50aWNhdGlvbi5GcmFtYWJsZVJlcXVlc3SJGmN3l1VvvgIAA1oAC19pc0ZyYW1hYmxlTAAPX2FsbG93ZWRPcmlnaW5zcQB+ADtMAApfZm9yT3JpZ2lucQB+ABt4cAFzcgA1Y29tLmdvb2dsZS5jb21tb24uY29sbGVjdC5JbW11dGFibGVTZXQkU2VyaWFsaXplZEZvcm0AAAAAAAAAAAIAAVsACGVsZW1lbnRzcQB+ABV4cHVxAH4AAwAAAAJzcgAyc2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLndlYi5TdGFuZGFyZEFsbG93ZWRPcmlnaW51g1eVE+WsIAIAB0kADF9kZWZhdWx0UG9ydFoADF9pczEyN18wXzBfMVoACV9pc09yaWdpbkkABV9wb3J0TAAFX2hvc3RxAH4AG0wABV9wYXRocQB+ABtMAAlfcHJvdG9jb2xxAH4AG3hwAAABuwAB/////3QAC29hdXRoLnRvb2xzdAAAdAAFaHR0cHNzcQB+AEQAAAG7AAH/////dAASbG9naW4uY3VyaXR5LmxvY2FsdAAAdAAFaHR0cHNwQAAAAAAAAABxAH4AHAABcHNxAH4AQXEAfgAvc3IADmphdmEubGFuZy5Mb25nO4vkkMyPI98CAAFKAAV2YWx1ZXhyABBqYXZhLmxhbmcuTnVtYmVyhqyVHQuU4IsCAAB4cH//////////dAADZ2V0c3IAL2NvbS5nb29nbGUuY29tbW9uLmNvbGxlY3QuSW1tdXRhYmxlTGlzdE11bHRpbWFwAAAAAAAAAAADAAB4cgArY29tLmdvb2dsZS5jb21tb24uY29sbGVjdC5JbW11dGFibGVNdWx0aW1hcAAAAAAAAAAAAgAAeHB3BAAAAAR0ABFzZXJ2aWNlUHJvdmlkZXJJZHcEAAAAAXEAfgAddAAJY2xpZW50X2lkdwQAAAABcQB+AB50AApyZXN1bWVQYXRodwQAAAABdAAZL29hdXRoL3YyL29hdXRoLWF1dGhvcml6ZXQABXN0YXRldwQAAAABdAAiUl9NZWN0UWt6bkRtWGFKdVlJQ3BpY1F0dUtkOENrTUdpcXhzcgARamF2YS51dGlsLkhhc2hTZXS6RIWVlri3NAMAAHhwdwwAAAACP0AAAAAAAAFzcgBDc2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLmF1dGhlbnRpY2F0aW9uLkF1dGhlbnRpY2F0b3JJZGVudGlmaWVyUGFpctQv4PlUPR0pAgABTAAFX3BhaXJ0AC5Mb3JnL2FwYWNoZS9jb21tb25zL2xhbmczL3R1cGxlL0ltbXV0YWJsZVBhaXI7eHBzcgAsb3JnLmFwYWNoZS5jb21tb25zLmxhbmczLnR1cGxlLkltbXV0YWJsZVBhaXJEw2h6ber/0QIAAkwABGxlZnRxAH4AAUwABXJpZ2h0cQB+AAF4cgAjb3JnLmFwYWNoZS5jb21tb25zLmxhbmczLnR1cGxlLlBhaXJEw2h6ber/0QIAAHhwdAAQVXNlcm5hbWVQYXNzd29yZHQAN3VybjpzZTpjdXJpdHk6YXV0aGVudGljYXRpb246aHRtbC1mb3JtOlVzZXJuYW1lUGFzc3dvcmR4cQB+AB1xAH4AWH5yADZzZS5jdXJpdHkuaWRlbnRpdHlzZXJ2ZXIuYXV0aGVudGljYXRpb24uU3NvUmVxdWlyZW1lbnQAAAAAAAAAABIAAHhxAH4AJ3QABE5PTkVxAH4AWnBzcQB+ABFzcQB+ABR1cQB+AAMAAAABdAAXZGVmYXVsdC1zaW1wbGUtcHJvdG9jb2xzcQB+ABFzcQB+ABR1cQB+AAMAAAABc3EAfgBOAAAAAGCSalFzcQB+ABFzcQB+ABR1cQB+AAMAAAABdAB5Y2xpZW50X2lkPWhhYXBpLXdlYi1jbGllbnQmcmVkaXJlY3RfdXJpPWh0dHBzJTNBJTJGJTJGbG9jYWxob3N0JTNBNzc3NyUyRmNhbGxiYWNrJnJlc3BvbnNlX3R5cGU9Y29kZSZzY29wZT1yZWFkJnN0YXRlPWZvb3NxAH4AEXNxAH4AFHVxAH4AAwAAAAFzcgARamF2YS5sYW5nLkludGVnZXIS4qCk94GHOAIAAUkABXZhbHVleHEAfgBPAAAAAXNxAH4AEXNxAH4AFHVxAH4AAwAAAAFzcgA8c2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLndlYi5EZWZhdWx0UXVlcnlQYXJhbWV0ZXJDb2xsZWN0aW9uPMdTMxTFwVwCAAJMAAtfcGFyYW1ldGVyc3EAfgA6TAAMX3F1ZXJ5U3RyaW5ncQB+ABt4cHNxAH4AUncEAAAABXQACWNsaWVudF9pZHcEAAAAAXQAEGhhYXBpLXdlYi1jbGllbnR0AAxyZWRpcmVjdF91cml3BAAAAAF0AB9odHRwczovL2xvY2FsaG9zdDo3Nzc3L2NhbGxiYWNrdAANcmVzcG9uc2VfdHlwZXcEAAAAAXQABGNvZGV0AAVzY29wZXcEAAAAAXQABHJlYWR0AAVzdGF0ZXcEAAAAAXQAA2Zvb3hxAH4Ac3NxAH4AEXNxAH4AFHVxAH4AAwAAAAFzcgA/c2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLmhhYXBpLkhhYXBpQWNjZXNzQ29udHJvbEZpbHRlciRBYXRJbmZvX/JZDOO6bPgCAAdaABFjYW5Vc2VBcGlPbkJlaGFsZkoAA2V4cEwACGNsaWVudElkcQB+ABtMAAZpc3N1ZXJxAH4AG0wADWp3a1RodW1icHJpbnRxAH4AG0wACXByb2ZpbGVJZHEAfgAbTAAJdG9rZW5IYXNocQB+ABt4cAAAAAAAYJJrfHQAEGhhYXBpLXdlYi1jbGllbnR0ADNodHRwczovL2xvZ2luLmN1cml0eS5sb2NhbC9vYXV0aC92Mi9vYXV0aC1hbm9ueW1vdXN0ACtKZXhRWC1weG02aXBuV3drZ1E0Z0Y4LUpfZU5aNjNUX1VlYy1PQ1pKRFE4dAANdG9rZW4tc2VydmljZXQALHNCVGNad1ZWOHFZa21YZTRnWTJ5dEJmRUlCWGxhb1R1YW9pXzcwWU5ycFE9c3EAfgARc3EAfgAUdXEAfgADAAAAAXQAJDNhNzU0NGU5LWQ2NjgtNDRkYy05Y2ZjLWJiYjM1MDZlY2MzZg==	1620210042
2100482e-cc18-4af8-a57c-a3b70c212318	rO0ABXNyADVjb20uZ29vZ2xlLmNvbW1vbi5jb2xsZWN0LkltbXV0YWJsZU1hcCRTZXJpYWxpemVkRm9ybQAAAAAAAAAAAgACTAAEa2V5c3QAEkxqYXZhL2xhbmcvT2JqZWN0O0wABnZhbHVlc3EAfgABeHB1cgATW0xqYXZhLmxhbmcuT2JqZWN0O5DOWJ8QcylsAgAAeHAAAAAIdAAeX2F1dGhuLXJlcS5zZXJ2aWNlLXByb3ZpZGVyLWlkdAAZQVVUSE5fSU5URVJNRURJQVRFX1JFU1VMVHQAOWFwaVNzby1fYXV0aG5TU08uYWY5YzcxNGQ2YjRkODU4MzE1OWM3ODM1MDg4ODRlYmU0ZDY3YTE1NnQADl9fYXV0aG5SZXF1ZXN0dAAhU1RBUlRfQVVUSE5fVElNRV9BU19FUE9DSF9TRUNPTkRTdAAZVXNlcm5hbWVQYXNzd29yZC5hdHRlbXB0c3QADWhhYXBpLWFhdC1rZXl0AA5fdHJhbnNhY3Rpb25JZHVxAH4AAwAAAAhzcgA8c2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLnNlc3Npb24uSW50ZXJuYWxTZXNzaW9uJFNlc3Npb25EYXRha/zdOk3KalwCAAFMAAZfdmFsdWV0AClMY29tL2dvb2dsZS9jb21tb24vY29sbGVjdC9JbW11dGFibGVMaXN0O3hwc3IANmNvbS5nb29nbGUuY29tbW9uLmNvbGxlY3QuSW1tdXRhYmxlTGlzdCRTZXJpYWxpemVkRm9ybQAAAAAAAAAAAgABWwAIZWxlbWVudHN0ABNbTGphdmEvbGFuZy9PYmplY3Q7eHB1cQB+AAMAAAABc3IATXNlLmN1cml0eS5pZGVudGl0eXNlcnZlci5wbHVnaW4ucHJvdG9jb2wuc2ltcGxlYXBpLlNpbXBsZUFwaVNlcnZpY2VQcm92aWRlcklkt55a24rmGB4CAAJaABdfaXNPQXV0aFNlcnZpY2VQcm92aWRlckwACV9jbGllbnRJZHQANUxzZS9jdXJpdHkvaWRlbnRpdHlzZXJ2ZXIvZGF0YS9kb21haW4vb2F1dGgvQ2xpZW50SWQ7eHIAPHNlLmN1cml0eS5pZGVudGl0eXNlcnZlci5wbHVnaW5zLnByb3RvY29scy5TZXJ2aWNlUHJvdmlkZXJJZLCqJHYgMJVyAgACTAAKX3Byb2ZpbGVJZHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wABl92YWx1ZXEAfgAYeHB0AA10b2tlbi1zZXJ2aWNldAAQaGFhcGktd2ViLWNsaWVudAFzcgAzc2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLmRhdGEuZG9tYWluLm9hdXRoLkNsaWVudElk6Xcrgw5afB8CAANaAAZfdmFsaWRMAAlfY2xpZW50SWRxAH4AGEwAEF9lc3RhYmxpc2hlZEZyb210ABNMamF2YS91dGlsL0VudW1TZXQ7eHABcQB+ABtzcgAkamF2YS51dGlsLkVudW1TZXQkU2VyaWFsaXphdGlvblByb3h5BQfT23ZUytECAAJMAAtlbGVtZW50VHlwZXQAEUxqYXZhL2xhbmcvQ2xhc3M7WwAIZWxlbWVudHN0ABFbTGphdmEvbGFuZy9FbnVtO3hwdnIAQ3NlLmN1cml0eS5pZGVudGl0eXNlcnZlci5kYXRhLmRvbWFpbi5vYXV0aC5DbGllbnRJZCRFc3RhYmxpc2hlZEZyb20AAAAAAAAAABIAAHhyAA5qYXZhLmxhbmcuRW51bQAAAAAAAAAAEgAAeHB1cgARW0xqYXZhLmxhbmcuRW51bTuojeotM9IvmAIAAHhwAAAAAX5xAH4AI3QADFFVRVJZX1NUUklOR3NxAH4ADnNxAH4AEXVxAH4AAwAAAABzcQB+AA5zcQB+ABF1cQB+AAMAAAABc3IAT3NlLmN1cml0eS5pZGVudGl0eXNlcnZlci5hdXRobi5jb250cm9sbGVycy5IYWFwaVNzb01hbmFnZXIkRXhwaXJhYmxlU3NvU2Vzc2lvbnOmGGDhF6QHYAIAAkwAC19leHBpcmF0aW9udAATTGphdmEvdGltZS9JbnN0YW50O0wAFl9zZXJpYWxpemVkU3NvU2Vzc2lvbnNxAH4AGHhwc3IADWphdmEudGltZS5TZXKVXYS6GyJIsgwAAHhwdw0CAAAAAGCSeIgxLIBAeHQCdlt7Il9hY3IiOiJ1cm46c2U6Y3VyaXR5OmF1dGhlbnRpY2F0aW9uOmh0bWwtZm9ybTpVc2VybmFtZVBhc3N3b3JkIiwiX2F0dHJpYnV0ZXMiOnsic3ViamVjdCI6eyJhY2NvdW50SWQiOiI1Y2RhYjczMC1hZDg3LTExZWItYjk2Zi0wMjQyYWMxMTAwMDgiLCJ1c2VyTmFtZSI6ImpvaG4uZG9lIiwic3ViamVjdCI6ImpvaG4uZG9lIn0sImNvbnRleHQiOnsiYXV0aF90aW1lIjoxNjIwMjA4MjQ4LCJhY3IiOiJ1cm46c2U6Y3VyaXR5OmF1dGhlbnRpY2F0aW9uOmh0bWwtZm9ybTpVc2VybmFtZVBhc3N3b3JkIiwiYXV0aGVudGljYXRpb25TZXNzaW9uRGF0YSI6eyJzZXJ2aWNlUHJvdmlkZXJQcm9maWxlSWQiOiJ0b2tlbi1zZXJ2aWNlIiwic2VydmljZVByb3ZpZGVySWQiOiJoYWFwaS13ZWItY2xpZW50Iiwic2lkIjoiWjRMaTcxckI0WmZySFJYUiJ9fX0sIl9uYW1lRm9ybWF0IjoidW5zcGVjaWZpZWQiLCJfdHJhbnNhY3Rpb25JZCI6IjZlOWYxYWM4LWRlNDAtNDY1ZS1hZjdiLTk5N2JlNDBmYThiZSIsIl9leHBpcmF0aW9uSW5zdGFudCI6eyJzZWNvbmRzIjoxNjIwMjExODQ4LCJuYW5vcyI6ODI1MDAwMDAwfSwiX2F1dGhlbnRpY2F0aW9uSW5zdGFudCI6eyJzZWNvbmRzIjoxNjIwMjA4MjQ4LCJuYW5vcyI6MH19XXNxAH4ADnEAfgArc3EAfgAOc3EAfgARdXEAfgADAAAAAXNyAA5qYXZhLmxhbmcuTG9uZzuL5JDMjyPfAgABSgAFdmFsdWV4cgAQamF2YS5sYW5nLk51bWJlcoaslR0LlOCLAgAAeHAAAAAAYJJqYHNxAH4ADnNxAH4AEXVxAH4AAwAAAAFzcgARamF2YS5sYW5nLkludGVnZXIS4qCk94GHOAIAAUkABXZhbHVleHEAfgA7AAAAAHNxAH4ADnNxAH4AEXVxAH4AAwAAAAFzcgA/c2UuY3VyaXR5LmlkZW50aXR5c2VydmVyLmhhYXBpLkhhYXBpQWNjZXNzQ29udHJvbEZpbHRlciRBYXRJbmZvX/JZDOO6bPgCAAdaABFjYW5Vc2VBcGlPbkJlaGFsZkoAA2V4cEwACGNsaWVudElkcQB+ABhMAAZpc3N1ZXJxAH4AGEwADWp3a1RodW1icHJpbnRxAH4AGEwACXByb2ZpbGVJZHEAfgAYTAAJdG9rZW5IYXNocQB+ABh4cAAAAAAAYJJri3QAEGhhYXBpLXdlYi1jbGllbnR0ADNodHRwczovL2xvZ2luLmN1cml0eS5sb2NhbC9vYXV0aC92Mi9vYXV0aC1hbm9ueW1vdXN0ACtZTy1QNm54YlNHMjFqV0lYZG82bXBMUkVqQURzVGRLci1jOG5WQ0pfRTA4dAANdG9rZW4tc2VydmljZXQALExQaklEZUNCanppTmJBUDJrdXlMeWRQZ1BheWdBZFlUTE9ydVBZajVSekE9c3EAfgAOc3EAfgARdXEAfgADAAAAAXQAJDZlOWYxYWM4LWRlNDAtNDY1ZS1hZjdiLTk5N2JlNDBmYThiZQ==	1620210079
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (token_hash, id, delegations_id, purpose, usage, format, created, expires, scope, scope_claims, status, issuer, subject, audience, not_before, claims, meta_data) FROM stdin;
\.


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (subject, purpose);


--
-- Name: delegations delegations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delegations
    ADD CONSTRAINT delegations_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: dynamically_registered_clients dynamically_registered_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dynamically_registered_clients
    ADD CONSTRAINT dynamically_registered_clients_pkey PRIMARY KEY (client_id);


--
-- Name: linked_accounts linked_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linked_accounts
    ADD CONSTRAINT linked_accounts_pkey PRIMARY KEY (linked_account_id, linked_account_domain_name);


--
-- Name: nonces nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nonces
    ADD CONSTRAINT nonces_pkey PRIMARY KEY (token);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token_hash);


--
-- Name: idx_accounts_attributes_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_attributes_name ON public.accounts USING gin (((attributes -> 'name'::text)));


--
-- Name: idx_accounts_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_accounts_email ON public.accounts USING btree (email);


--
-- Name: idx_accounts_phone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_accounts_phone ON public.accounts USING btree (phone);


--
-- Name: idx_accounts_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_accounts_username ON public.accounts USING btree (username);


--
-- Name: idx_buckets_attributes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_buckets_attributes ON public.buckets USING gin (attributes);


--
-- Name: idx_delegations_authorization_code_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_authorization_code_hash ON public.delegations USING btree (authorization_code_hash);


--
-- Name: idx_delegations_client_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_client_id ON public.delegations USING btree (client_id);


--
-- Name: idx_delegations_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_expires ON public.delegations USING btree (expires);


--
-- Name: idx_delegations_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_owner ON public.delegations USING btree (owner);


--
-- Name: idx_delegations_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_status ON public.delegations USING btree (status);


--
-- Name: idx_devices_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_devices_account_id ON public.devices USING btree (account_id);


--
-- Name: idx_devices_device_id_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_devices_device_id_account_id ON public.devices USING btree (device_id, account_id);


--
-- Name: idx_drc_attributes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drc_attributes ON public.dynamically_registered_clients USING gin (attributes);


--
-- Name: idx_drc_instance_of_client; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drc_instance_of_client ON public.dynamically_registered_clients USING btree (instance_of_client);


--
-- Name: idx_linked_accounts_accounts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_linked_accounts_accounts_id ON public.linked_accounts USING btree (account_id);


--
-- Name: idx_sessions_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_id ON public.sessions USING btree (id);


--
-- Name: idx_sessions_id_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_id_expires ON public.sessions USING btree (id, expires);


--
-- Name: idx_tokens_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_expires ON public.tokens USING btree (expires);


--
-- Name: idx_tokens_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_id ON public.tokens USING btree (id);


--
-- Name: idx_tokens_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_status ON public.tokens USING btree (status);


--
-- PostgreSQL database dump complete
--

