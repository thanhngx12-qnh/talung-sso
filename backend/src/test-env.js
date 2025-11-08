// backend/src/test-env.js - Test environment loading

import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, '../../.env.local') });

console.log('Environment Test:');
console.log('API_PORT:', process.env.API_PORT);
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('KEYCLOAK_URL:', process.env.KEYCLOAK_URL);