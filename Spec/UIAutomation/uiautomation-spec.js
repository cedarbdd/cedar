describe("UIAutomation", function() {
  describe("a passing test", function() {
    it("should pass", function() {
      UIALogger.logDebug("I should pass");
      expect(true).toBe(true);
    });
  });
  
  describe("a failing test", function() {
    it("should fail", function() {
      expect(true).toBe(false);
    });
  });
});