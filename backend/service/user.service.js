import bcrypt from "bcryptjs";
import User from "../models/user.js";

export const createUser = async ({
  name,
  email,
  phone,
  password,
  role = "user"
}) => {
  const exists = await User.findOne({ email });
  if (exists) throw new Error("User already exists");

  const hashedPassword = await bcrypt.hash(password, 10);

  return await User.create({
    name,
    email,
    phone,
    password: hashedPassword,
    role
  });
};
