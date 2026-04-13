const User = require('../models/User');

// login user
exports.login = async (req, res) => {
  try {
    const { matricule, phone } = req.body;
    const user = await User.findOne({ matricule, phone });
    if (!user) {
      return res.status(401).json({ message: "Identifiants invalides" });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json(err);
  }
};

// get all users (Admin)
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find().sort({ created_at: -1 });
    res.json(users);
  } catch (err) {
    res.status(500).json(err);
  }
};

// create user
exports.createUser = async (req, res) => {
  try {
    const user = new User(req.body);
    await user.save();
    res.json(user);
  } catch (err) {
    res.status(500).json(err);
  }
};

// get user by matricule
exports.getUser = async (req, res) => {
  try {
    const user = await User.findOne({ matricule: req.params.matricule });
    res.json(user);
  } catch (err) {
    res.status(500).json(err);
  }
};

// update user
exports.updateUser = async (req, res) => {
  try {
    const user = await User.findOneAndUpdate(
      { matricule: req.params.matricule },
      req.body,
      { new: true }
    );
    res.json(user);
  } catch (err) {
    res.status(500).json(err);
  }
};