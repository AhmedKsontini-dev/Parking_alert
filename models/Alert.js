const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema({
  senderMatricule: { type: String, required: true },
  receiverMatricule: { type: String, required: true },
  senderPhone: { type: String },
  message: { type: String, required: true },
   status: { type: String, default: "pending" },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Alert', alertSchema);