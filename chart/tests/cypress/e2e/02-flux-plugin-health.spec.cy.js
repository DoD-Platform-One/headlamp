describe("Flux Plugin Check", function () {
  it("Check Flux Plugin is installed", function () {
    cy.visit(Cypress.env("url"), { timeout: 15000 });

    cy.request("GET", "/plugins").then((response) => {
      assert.isTrue(response.body.includes("static-plugins/flux"));
    });
  });
});
