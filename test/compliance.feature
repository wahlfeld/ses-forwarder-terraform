Feature: Infrastructure code should meet certain requirements
  In order to improve infrastructure code quality
  As engineers
  We'll use terraform-compliance to enforce good infrastructure practices

  Scenario Outline: Ensure that specific tags are defined
    Given I have resource that supports tags defined
    Then it must contain <tags>
    And its value must match the "<value>" regex

    Examples:
      | tags        | value              |
      | CreatedBy   | ^(Terraform)$      |
      | ModuleName  | ^(ses-forwarder)$   |

  Scenario Outline: AWS Credentials should not be hardcoded
    Given I have aws provider configured
    When it has <key>
    Then its value must not match the "<regex>" regex

    Examples:
        | key        | regex                                                      |
        | access_key | (?<![A-Z0-9])[A-Z0-9]{20}(?![A-Z0-9])                      |
        | secret_key | (?<![A-Za-z0-9\/+=])[A-Za-z0-9\/+=]{40}(?![A-Za-z0-9\/+=]) | 

  Scenario: No publicly open ports
      Given I have AWS Security Group defined
      When it contains ingress
      Then it must not have tcp protocol and port 1024-65535 for 0.0.0.0/0
