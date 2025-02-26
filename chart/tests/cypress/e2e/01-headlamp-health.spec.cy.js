describe('Basic Headlamp', function() {
  it('Check Headlamp is accessible', function() {
    cy.visit(Cypress.env('url'), { timeout: 15000 })
    cy.title().should('include', 'Headlamp');
  })
})

