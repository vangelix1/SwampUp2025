// authMiddleware.js
const jwt = require('jsonwebtoken');
const CONFIG = require('./config');

// Simulated User "Database"
const User = {
  findOne: async ({ _id }) => {
    if (_id === "123") return { id: "123", name: "<b>Test User</b>" };
    return null;
  }
};

const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const decoded = jwt.verify(token, CONFIG.jwt_secret_key);

      // Get user from the token and attach to request object
      req.user = await User.findOne({ _id: decoded.id });
      
      if (!req.user) {
         return res.status(401).send('Not authorized, user not found');
      }

      next(); // Move to the next piece of middleware/route handler
    } catch (error) {
      console.error(error);
      return res.status(401).send('Not authorized, token failed');
    }
  }

  if (!token) {
    return res.status(401).send('Not authorized, no token');
  }
};

module.exports = { protect };