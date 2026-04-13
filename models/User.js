const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  matricule: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  fcmToken: { type: String },
  frontCardImage: { type: String }, // Base64 String
  backCardImage: { type: String },  // Base64 String
  isApproved: { type: Boolean, default: false }, // Status de validation par l'admin
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', userSchema);