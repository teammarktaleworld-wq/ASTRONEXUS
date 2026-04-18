const mongoose = require('mongoose');

const wishlistSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // optional ref to User
  products: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }] // reference Product collection
}, { timestamps: true });

module.exports = mongoose.model('Wishlist', wishlistSchema);