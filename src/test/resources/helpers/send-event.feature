Feature: Helper - enviar un evento al Barista Bot

  Scenario: Enviar evento
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: '#(evento)' }
    When method post
    Then status 200