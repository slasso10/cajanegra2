Feature: Helper - dejar el Barista Bot en un estado dado

  Scenario: Reiniciar y avanzar hasta el estado objetivo
    * def paths =
    """
    {
      'En Espera': [],
      'Moliendo': ['Iniciar Pedido'],
      'Calentando Agua': ['Iniciar Pedido', 'Terminar Molienda'],
      'Sirviendo': ['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura'],
      'Error de Insumos': ['Iniciar Pedido', 'Sin Ingredientes']
    }
    """
    * def playEvents =
    """
    function(events) {
      for (var i = 0; i < karate.sizeOf(events); i++) {
        karate.call('classpath:helpers/send-event.feature', { evento: events[i] });
      }
    }
    """

    Given url baseUrl
    And path 'barista-bot/reiniciar'
    When method post
    Then status 200
    And match response.estadoActual == 'En Espera'

    * eval playEvents(paths[targetState])

    Given url baseUrl
    And path 'barista-bot/estado'
    When method get
    Then status 200
    And match response.estadoActual == targetState