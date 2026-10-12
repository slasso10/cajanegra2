@api @climatizacion
Feature: Controlador de climatización inteligente (tabla de decisión)

  Background:
    Given url baseUrl
    And path 'decision/climatizacion/reiniciar'
    When method post
    Then status 200
    And match response.ok == true

  @Issue-12 @REQ-CLI-R1
  Scenario: Regla 1 - Puertas abiertas sin calor ni presencia apaga el sistema y alerta
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And header Content-Type = 'application/json'
    And request { valores: [false, false, true] }
    When method post
    Then status 200
    And match response.valores == [false, false, true]
    And match response.reglaIndex == 0
    And match response.accion == 'Apagar sistema de climatización y emitir alerta sonora'
    And match response.noDefinida == false

  @Issue-13 @REQ-CLI-R2
  Scenario: Regla 2 - Calor con presencia y puertas cerradas enciende refrigeración
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And header Content-Type = 'application/json'
    And request { valores: [true, true, false] }
    When method post
    Then status 200
    And match response.valores == [true, true, false]
    And match response.reglaIndex == 1
    And match response.accion == 'Encender aire acondicionado en modo refrigeración'
    And match response.noDefinida == false

  @Issue-14 @REQ-CLI-R3
  Scenario: Regla 3 - Calor sin presencia mantiene bajo consumo
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And header Content-Type = 'application/json'
    And request { valores: [true, false, false] }
    When method post
    Then status 200
    And match response.valores == [true, false, false]
    And match response.reglaIndex == 2
    And match response.accion == 'Mantener en modo de bajo consumo energético'
    And match response.noDefinida == false

  @smoketest @Issue-15 @REQ-CLI-R4
  Scenario: Regla 4 - Ninguna condición mantiene el sistema apagado
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And header Content-Type = 'application/json'
    And request { valores: [false, false, false] }
    When method post
    Then status 200
    And match response.valores == [false, false, false]
    And match response.reglaIndex == 3
    And match response.accion == 'Mantener sistema apagado'
    And match response.noDefinida == false