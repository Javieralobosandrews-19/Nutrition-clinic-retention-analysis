# Dados

Este projeto utiliza **dados simulados** de uma clínica de nutrição.

Para executar o notebook do início ao fim, adicione nesta pasta os quatro arquivos abaixo:

- `patients.csv`
- `consultations.csv`
- `nutritionists.csv`
- `payments.csv`

## Estrutura esperada

### `patients.csv`
| Coluna | Descrição |
|---|---|
| `patient_id` | Identificador do paciente |
| `age` | Idade |
| `gender` | Gênero |
| `city` | Cidade |
| `goal` | Objetivo do acompanhamento nutricional |

### `consultations.csv`
| Coluna | Descrição |
|---|---|
| `consultation_id` | Identificador da consulta |
| `patient_id` | Identificador do paciente |
| `nutritionist_id` | Identificador do nutricionista |
| `consultation_date` | Data da consulta |
| `consultation_type` | Primeira consulta ou retorno |
| `attended` | Indicador de comparecimento (1/0) |

### `nutritionists.csv`
| Coluna | Descrição |
|---|---|
| `nutritionist_id` | Identificador do nutricionista |
| `name` | Nome simulado |
| `specialty` | Especialidade |

### `payments.csv`
| Coluna | Descrição |
|---|---|
| `payment_id` | Identificador do pagamento |
| `consultation_id` | Consulta associada |
| `amount_brl` | Valor registrado em BRL |
| `payment_method` | Método de pagamento |
