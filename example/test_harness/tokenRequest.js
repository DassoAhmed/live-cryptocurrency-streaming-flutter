// Example to run tokenRequest server:
// This server will return TokenRequest json on making get call to `/auth` endpoint
// node tokenRequest "your-app-key"
// node tokenRequest "I2E_JQ.79AfrA:sw2y9zarxwl0Lw5a"

const Ably = require('ably');

const ApiKey = process.argv[2];
if (!ApiKey) {
  throw 'Cannot run without an API key. Add your key to example.js';
}
var rest = new Ably.Rest({key: ApiKey});

const express = require('express'),
  app = express();

app.get('/auth', function (req, res) {
  var tokenParams;
  /* Check if the user wants to log in */
  if (req.query['username']) {
    /* Issue a token request with pub & sub permissions on all channels +
       configure the token with an identity */
    tokenParams = {
      capability: {'*': ['publish', 'subscribe', 'history', 'presence']},
      clientId: req.cookies.username,
    };
  } else {
    /* Issue a token with subscribe privileges restricted to one channel
       and configure the token without an identity (anonymous) */
    tokenParams = {
      capability: {'*': ['publish', 'subscribe', 'history', 'presence']},
      ttl: 15000,
    };
  }
  rest.auth.createTokenRequest(tokenParams, function (err, tokenRequest) {
    if (err) {
      let message = 'Error requesting token: ' + JSON.stringify(err);
      console.log(message);
      res.status(500).send(message);
    } else {
      console.log(
        'token request successful\n',
        JSON.stringify(tokenRequest, null, 2)
      );
      res.setHeader('Content-Type', 'application/json');
      res.send(JSON.stringify(tokenRequest));
    }
  });
});

app.use('/', (req, res) =>
  res.send('use `/auth` endpoint to acquire token request')
);

app.listen(3000, function () {
  // getting localIP Address from network interfaces
  const localIp = Object.values(require('os').networkInterfaces())
    .map((interface) =>
      interface.filter((net) => net.family === 'IPv4' && net.internal === false)
    )
    .filter((_) => _.length)[0][0].address;
  console.log(
    `Web server listening on port 3000. Visit http://${localIp}:3000/auth to get requestToken`
  );
});
