@api @baristaBot
Feature: Ciclo de preparación de bebidas del Barista Bot (transición de estados)

  # ---------- Transiciones válidas ----------
  @smoketest @Issue-1 @REQ-BAR-A
  Scenario: Iniciar pedido desde En Espera pasa a Moliendo
    * call read('classpath:helpers/barista-state.feature') { targetState: 'En Espera' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Iniciar Pedido' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'En Espera'
    And match response.estadoNuevo == 'Moliendo'
    And match response.valida == true

  @Issue-2 @REQ-BAR-B
  Scenario: Terminar molienda pasa a Calentando Agua
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Moliendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Terminar Molienda' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Moliendo'
    And match response.estadoNuevo == 'Calentando Agua'
    And match response.valida == true

  @Issue-3 @REQ-BAR-C
  Scenario: Alcanzar temperatura pasa a Sirviendo
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Calentando Agua' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Alcanzar Temperatura' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Calentando Agua'
    And match response.estadoNuevo == 'Sirviendo'
    And match response.valida == true

  @Issue-4 @REQ-BAR-C
  Scenario: Terminar llenado retorna a En Espera
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Sirviendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Terminar Llenado' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Sirviendo'
    And match response.estadoNuevo == 'En Espera'
    And match response.valida == true

  @Issue-5 @REQ-BAR-D
  Scenario: Sin ingredientes mientras muele pasa a Error de Insumos
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Moliendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Moliendo'
    And match response.estadoNuevo == 'Error de Insumos'
    And match response.valida == true

  @Issue-6 @REQ-BAR-D
  Scenario: Sin ingredientes mientras calienta agua pasa a Error de Insumos
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Calentando Agua' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Calentando Agua'
    And match response.estadoNuevo == 'Error de Insumos'
    And match response.valida == true

  @Issue-7 @REQ-BAR-D
  Scenario: Sin ingredientes mientras sirve pasa a Error de Insumos
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Sirviendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Sirviendo'
    And match response.estadoNuevo == 'Error de Insumos'
    And match response.valida == true

  @Issue-8 @REQ-BAR-D
  Scenario: Técnico recarga y reinicia desde Error de Insumos
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Error de Insumos' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: 'Recargar y Reiniciar' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Error de Insumos'
    And match response.estadoNuevo == 'En Espera'
    And match response.valida == true

  # ---------- Transiciones inválidas ----------
  @critical @Issue-9 @REQ-BAR-D
  Scenario Outline: Error de Insumos bloquea el evento <evento>
    * call read('classpath:helpers/barista-state.feature') { targetState: 'Error de Insumos' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: '<evento>' }
    When method post
    Then status 200
    And match response.valida == false
    And match response.noDefinida == true
    And match response.estadoNuevo == 'Error de Insumos'

    Given url baseUrl
    And path 'barista-bot/estado'
    When method get
    Then status 200
    And match response.estadoActual == 'Error de Insumos'

    Examples:
      | evento               |
      | Iniciar Pedido       |
      | Terminar Molienda    |
      | Alcanzar Temperatura |
      | Terminar Llenado     |
      | Sin Ingredientes     |

  @Issue-10 @REQ-BAR-INV
  Scenario Outline: En Espera rechaza el evento <evento>
    * call read('classpath:helpers/barista-state.feature') { targetState: 'En Espera' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: '<evento>' }
    When method post
    Then status 200
    And match response.valida == false
    And match response.noDefinida == true
    And match response.estadoNuevo == 'En Espera'

    Given url baseUrl
    And path 'barista-bot/estado'
    When method get
    Then status 200
    And match response.estadoActual == 'En Espera'

    Examples:
      | evento               |
      | Terminar Molienda    |
      | Alcanzar Temperatura |
      | Terminar Llenado     |
      | Sin Ingredientes     |
      | Recargar y Reiniciar |

  @Issue-11 @REQ-BAR-INV
  Scenario Outline: <estado_actual> rechaza el evento <evento>
    * call read('classpath:helpers/barista-state.feature') { targetState: '<estado_actual>' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And header Content-Type = 'application/json'
    And request { evento: '<evento>' }
    When method post
    Then status 200
    And match response.valida == false
    And match response.noDefinida == true
    And match response.estadoNuevo == '<estado_actual>'

    Given url baseUrl
    And path 'barista-bot/estado'
    When method get
    Then status 200
    And match response.estadoActual == '<estado_actual>'

    Examples:
      | estado_actual   | evento               |
      | Moliendo        | Iniciar Pedido       |
      | Moliendo        | Alcanzar Temperatura |
      | Moliendo        | Terminar Llenado     |
      | Moliendo        | Recargar y Reiniciar |
      | Calentando Agua | Iniciar Pedido       |
      | Calentando Agua | Terminar Molienda    |
      | Calentando Agua | Terminar Llenado     |
      | Calentando Agua | Recargar y Reiniciar |
      | Sirviendo       | Iniciar Pedido       |
      | Sirviendo       | Terminar Molienda    |
      | Sirviendo       | Alcanzar Temperatura |
      | Sirviendo       | Recargar y Reiniciar |