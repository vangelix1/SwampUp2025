require('dotenv').config();

let CONFIG = {};

// Current ENV
CONFIG.current_env = process.env.CURRENT_ENV || 'production';

// Port
CONFIG.port = process.env.PORT || '3001';

// Database
CONFIG.mongodb_uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/hello-api';

// JWT
CONFIG.jwt_secret_key =
   process.env.JWT_SECRET_KEY || 'f5HxCefwrdShD8P8ncPh4qFAktdnjAujASWjGxdmDVHHD4rZKWpBbjPEcDqmeP7u';
CONFIG.jwt_expiration = process.env.JWT_EXPIRATION || '1d';



module.exports = CONFIG;