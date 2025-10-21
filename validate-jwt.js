const crypto = require('crypto');

const jwtSecret = 'dev-secret-key-change-in-production';
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJwdWJsaWMtZGlyZWN0b3J5LXNlcnZpY2UiLCJpc3MiOiJlc3Bhc3lvLWZyb250ZW5kIiwiaWF0IjoxNzYwOTE1NDcwLCJleHAiOjE3NjA5MTkwNzAsInJvbGUiOiJQVUJMSUNfQVBJIiwiZW1haWwiOiJwdWJsaWMtZGlyZWN0b3J5QGVzcGFzeW8ubG9jYWwiLCJqdGkiOiJiMmUyYzVjMy0wN2RhLTQ3ZTItOGFlNC04OWJkZmJlMWIyMWMifQ.CWMOoqU_2CgrhPH9cFcl3myHKFdGKSl3ziwgURevuG8';

// Split the token
const parts = token.split('.');
if (parts.length !== 3) {
  console.log('Invalid JWT format');
  process.exit(1);
}

const header = parts[0];
const payload = parts[1];
const signature = parts[2];

// Verify signature
const signingInput = header + '.' + payload;
const expectedSignature = crypto.createHmac('sha256', jwtSecret).update(signingInput).digest('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

console.log('Expected signature:', expectedSignature);
console.log('Actual signature:', signature);
console.log('Signatures match:', expectedSignature === signature);

// Decode payload
const decodedPayload = Buffer.from(payload, 'base64').toString();
console.log('Decoded payload:', decodedPayload);

const claims = JSON.parse(decodedPayload);
console.log('Role claim:', claims.role);
console.log('Role is PUBLIC_API:', claims.role === 'PUBLIC_API');