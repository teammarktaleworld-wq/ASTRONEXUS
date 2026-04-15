/**
 * Store Service for managing product suggestions
 * This uses mock data for now, with structure ready for MongoDB integration.
 */

// Mock Product Database
const MOCK_PRODUCTS = [
    {
        id: 'p1',
        name: 'Black Tourmaline Pendant',
        description: 'A powerful stone for protection against negative energies and psychic attacks.',
        price: 499,
        currency: 'INR',
        category: 'Gemstones',
        tags: ['negative energy', 'protection', 'shani', 'saturn'],
        imageUrl: 'https://example.com/images/black-tourmaline.jpg',
        shopUrl: '/shop/products/p1'
    },
    {
        id: 'p2',
        name: 'Amethyst Crystal Cluster',
        description: 'Enhances spiritual awareness and provides a calming influence to the environment.',
        price: 850,
        currency: 'INR',
        category: 'Crystals',
        tags: ['peace', 'positivity', 'meditation', 'jupiter'],
        imageUrl: 'https://example.com/images/amethyst.jpg',
        shopUrl: '/shop/products/p2'
    },
    {
        id: 'p3',
        name: 'Vastu Pyramids (Set of 9)',
        description: 'Perfect for neutralizing Vastu Dosha and balancing energy flow in your home.',
        price: 1200,
        currency: 'INR',
        category: 'Vastu',
        tags: ['vastu', 'home', 'balance', 'negative energy'],
        imageUrl: 'https://example.com/images/vastu-pyramid.jpg',
        shopUrl: '/shop/products/p3'
    },
    {
        id: 'p4',
        name: 'Panchmukhi Rudraksha Bead',
        description: 'Authentic 5-faced Rudraksha for health, peace of mind, and general well-being.',
        price: 250,
        currency: 'INR',
        category: 'Spiritual',
        tags: ['health', 'peace', 'protection', 'general'],
        imageUrl: 'https://example.com/images/rudraksha.jpg',
        shopUrl: '/shop/products/p4'
    },
    {
        id: 'p5',
        name: 'Rose Quartz Love Stone',
        description: 'The stone of universal love. It restores trust and harmony in relationships.',
        price: 350,
        currency: 'INR',
        category: 'Crystals',
        tags: ['love', 'relationships', 'positivity', 'venus'],
        imageUrl: 'https://example.com/images/rose-quartz.jpg',
        shopUrl: '/shop/products/p5'
    },
    {
        id: 'p6',
        name: 'Copper Sun Wall Hanging',
        description: 'A powerful Vastu remedy for fame, success, and positive energy in the workplace.',
        price: 1500,
        currency: 'INR',
        category: 'Vastu',
        tags: ['success', 'sun', 'fame', 'positivity'],
        imageUrl: 'https://example.com/images/copper-sun.jpg',
        shopUrl: '/shop/products/p6'
    }
];

/**
 * Fetch all products (Mock)
 * @returns {Promise<Array>}
 */
export async function getAllProducts() {
    // In future, this will be: return await ProductModel.find({});
    return MOCK_PRODUCTS;
}

/**
 * Get product suggestions based on analysis
 * @param {Object} analysis - The planet analysis object from chat
 * @returns {Promise<Array>} Suggested products
 */
export async function getShopSuggestions(analysis) {
    try {
        // TO INTEGRATE WITH MONGODB:
        // 1. Import your Product model: import Product from '../models/Product.js';
        // 2. Fetch products: const products = await Product.find({ active: true });
        // 3. Replace MOCK_PRODUCTS with the fetched products.

        const products = MOCK_PRODUCTS;
        const { negativePercentage, planetBreakdown = [] } = analysis;

        // Identify negative influences
        const negativePlanets = planetBreakdown
            .filter(p => p.status === 'negative')
            .map(p => p.planet.toLowerCase());

        let suggestions = [];

        // Rule 1: High negative energy general remedy (Threshold adjusted to 40%)
        if (negativePercentage >= 40) {
            const protectionItem = products.find(p => p.tags.includes('negative energy'));
            if (protectionItem) suggestions.push(protectionItem);
        }

        // Rule 2: Planet-specific remedies
        negativePlanets.forEach(planetName => {
            const match = products.find(p => p.tags.includes(planetName));
            if (match && !suggestions.find(s => s.id === match.id)) {
                suggestions.push(match);
            }
        });

        // Rule 3: Always add a positivity booster if suggestions are low
        if (suggestions.length < 2) {
            const positivityItem = products.find(p => p.tags.includes('positivity') && !suggestions.find(s => s.id === p.id));
            if (positivityItem) suggestions.push(positivityItem);
        }

        // Fallback: If still nothing, just take first 2
        if (suggestions.length === 0) {
            suggestions = products.slice(0, 2);
        }

        // Return max 3 unique suggestions
        return suggestions.slice(0, 3);
    } catch (error) {
        console.error('[storeService] Error getting suggestions:', error);
        return MOCK_PRODUCTS.slice(0, 2);
    }
}

