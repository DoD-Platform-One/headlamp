describe("Flux Plugin Check", function () {
  it("Check Flux Plugin is installed", function () {
    cy.request("GET", Cypress.env("url") + '/plugins', { timeout: 15000 }).then((response) => {
        
        // Check for the flux plugin
        const responseString = JSON.stringify(response.body);
        expect(responseString).to.include('static-plugins/flux');
    });
  });
});
