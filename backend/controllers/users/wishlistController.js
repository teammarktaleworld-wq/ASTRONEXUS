import Wishlist from '../../models/shop/Wishlist.js';

/**
 * ADD PRODUCT TO WISHLIST
 * - One wishlist per user
 * - No duplicate products
 */
export const addWishlist = async (req, res) => {
  try {
    const userId = req.userId;
    const { productId } = req.body;

    if (!productId) {
      return res.status(400).json({ error: 'Product ID is required' });
    }

    let wishlist = await Wishlist.findOne({ userId });

    // Create wishlist if not exists
    if (!wishlist) {
      wishlist = new Wishlist({
        userId,
        products: [productId]
      });
    } else {
      // Prevent duplicate product
      if (!wishlist.products.some(p => p.toString() === productId)) {
        wishlist.products.push(productId);
      }
    }

    await wishlist.save();
    res.status(200).json(wishlist);

  } catch (err) {
    console.error('Add wishlist error:', err);
    res.status(400).json({ error: err.message });
  }
};

/**
 * GET LOGGED-IN USER WISHLIST
 */
export const getWishlist = async (req, res) => {
  try {
    const wishlist = await Wishlist.findOne({ userId: req.userId })
      .populate(
        'products',
        'name images price' // include the fields you need in Flutter
      );

    if (!wishlist) {
      return res.status(200).json({ products: [] });
    }

    res.status(200).json(wishlist);
  } catch (err) {
    console.error('Get wishlist error:', err);
    res.status(400).json({ error: err.message });
  }
};

/**
 * REMOVE PRODUCT FROM WISHLIST
 */
export const removeProduct = async (req, res) => {
  try {
    const { productId } = req.body;

    if (!productId) {
      return res.status(400).json({ error: 'Product ID is required' });
    }

    const wishlist = await Wishlist.findOne({ userId: req.userId });
    if (!wishlist) {
      return res.status(404).json({ error: 'Wishlist not found' });
    }

    wishlist.products = wishlist.products.filter(
      p => p.toString() !== productId
    );

    await wishlist.save();
    res.status(200).json(wishlist);

  } catch (err) {
    console.error('Remove wishlist product error:', err);
    res.status(400).json({ error: err.message });
  }
};