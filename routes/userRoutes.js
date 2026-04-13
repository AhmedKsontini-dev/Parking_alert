const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.get('/', userController.getAllUsers);
router.post('/register', userController.createUser);
router.post('/login', userController.login);
router.get('/:matricule', userController.getUser);
router.put('/:matricule', userController.updateUser);

module.exports = router;