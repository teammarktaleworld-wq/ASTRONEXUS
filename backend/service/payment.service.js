exports.verifyPayment = (paymentData) => {
  return paymentData.status === "success";
};
