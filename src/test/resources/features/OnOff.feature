Feature: Yo como tester quiero probar la funcionalidad de interruptor inteligente

  Scenario: Verificar el estado del interruptor en un momento dado
    Given url 'https://statemachine--maria7221.replit.app/api/'
    And path 'switch/state'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    When method get
    * print 'Estado actual del interruptor:', response.state
    * match responseStatus == 200




  @ignore @doOn
  Scenario: Do Turn On
    Given url 'https://statemachine--maria7221.replit.app/api/'
    And path 'switch/on'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And headers 'Content-Length': '0'
    When method post
    * print 'Response status when state is Off and do On :', responseStatus
    * match responseStatus == 200
    * match response == { state: 'on' }