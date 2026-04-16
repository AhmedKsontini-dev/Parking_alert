const Alert = require('../models/Alert');

// send alert
exports.sendAlert = async (req, res) => {
  try {
    const alert = new Alert(req.body);
    await alert.save();
    res.json(alert);
  } catch (err) {
    res.status(500).json(err);
  }
};

// get alerts for a user (sent or received)
exports.getAlerts = async (req, res) => {
  try {
    const alerts = await Alert.find({
      $or: [
        { receiverMatricule: req.params.matricule },
        { senderMatricule: req.params.matricule }
      ]
    }).sort({ created_at: -1 });

    res.json(alerts);
  } catch (err) {
    res.status(500).json(err);
  }
};

// update alert status
exports.updateAlertStatus = async (req, res) => {
  try {
    const alert = await Alert.findByIdAndUpdate(
      req.params.id,
      { status: req.body.status },
      { new: true }
    );
    res.json(alert);
  } catch (err) {
    res.status(500).json(err);
  }
};