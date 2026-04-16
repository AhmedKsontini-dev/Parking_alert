const express = require('express');
const router = express.Router();
const alertController = require('../controllers/alertController');

router.post('/send', alertController.sendAlert);
router.get('/:matricule', alertController.getAlerts);
router.put('/:id', alertController.updateAlertStatus);

module.exports = router;