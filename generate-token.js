const crypto = require('crypto');

const secret = 'dev-secret-key-change-in-production';
const role = 'PUBLIC_API';
const email = 'public-directory@espasyo.local';
const issuer = 'espasyo-frontend';
const subject = 'public-directory-service';
const now = Math.floor(Date.now() / 1000);
const expiresAt = now + 3600;

const payload = {
  sub: subject,
  iss: issuer,
  iat: now,
  exp: expiresAt,
  role: role,
  email: email,
  jti: crypto.randomUUID()
};

const header = { alg: 'HS256', typ: 'JWT' };
const encodedHeader = Buffer.from(JSON.stringify(header)).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
const encodedPayload = Buffer.from(JSON.stringify(payload)).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
const signingInput = encodedHeader + '.' + encodedPayload;
const signature = crypto.createHmac('sha256', secret).update(signingInput).digest('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
const token = signingInput + '.' + signature;

console.log('Generated JWT Token:');
console.log(token);