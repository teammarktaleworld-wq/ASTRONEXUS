const router = require("express").Router();
const c = require("../../controllers/admin/admin.cms.controller");
const { authenticateToken } = require("../../middlewares/auth.js");
const admin = require("../../middlewares/admin.middleware.js");

router.use(authenticateToken, admin);

router.post("/", c.create);
router.get("/", c.getAll);
router.put("/:id", c.update);

module.exports = router;
