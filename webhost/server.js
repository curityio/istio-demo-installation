var http = require('http');
var fs = require('fs');

const port = 3000;
http.createServer((request, response) => {

    fs.readFile('index.html', (error, content) => {

        const responseHeaders = {
            'Content-Type': 'text/html',
        };

        response.writeHead(200, responseHeaders);
        response.end(content, 'utf-8');
    })

}).listen(port);
console.log(`Web Host is listening at ${port}`);