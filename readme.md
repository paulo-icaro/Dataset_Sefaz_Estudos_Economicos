# Dataset Sefaz Estudos Econômicos (Asset - Sefaz CE)
Paulo Icaro
2026-11-09

<!------------->

<!-- Parte 1 -->

<!------------->

## Objetivo

<p>

      Este repositório contém todas as rotinas de tratamento final
responsáveis por estruturar o conjunto de dados que municiam os modelos
de análise do impacto do investimento público sobre a arrecadação de
ICMS.\
      A tabela a seguir resume informações referentes aos scripts:

</p>

| **Script** | **Fonte** | **Descrição** | **Tratamentos Aplicados** |
|:---|:---|:---|:---|
| ICMS_Dataset.R | Sefaz-CE | Dados de Arrecadação de ICMS | Ajuste da Frequência e Correção Monetária |
| Siof_Dataset.R | Seplag | Dados de Investimentos Públicos no Ceará | Ajuste da Frequência e Correção Monetária |
| Siconfi_Dataset.R | Siconfi | Acesso a dados dos relatórios RREO | Correção Monetária |
| Bacen_Dataset | Banco Central (SGS) | Acesso a variáveis macroeconômicas | Ajuste da Frequência e Correção Monetária |
| Ipeadata_Dataset | Instit. Ipea (Ipeadata) | Acesso a variáveis macroeconômicas | Ajuste da Frequência |
| Employment Dataset | Minist. Trabalho (MTE) | Construção da série de estoque empregos estimada e salário médio | Ajuste da Frequência e Correção Monetária |

<!------------->

<!-- Parte 2 -->

<!------------->

## Tratamentos Implementados

      Apesar de distintos, os scripts possuem etapas estão presentes em
quase todos os scripts. O fato da maioria dos dados ser de frequência
mensal implica que o ajuste de frequência é necessário. Para valores
monetários, é importante reajustá-los de acordo com a inflação. Para
cada um dos procedimentos, respectivamente, as funções
[**frequency_transforming**](https://github.com/paulo-icaro/Variables_Frequency_Transforming)
e
[**value_updating**](https://github.com/paulo-icaro/Update_Variables_Actual_Value)
são aplicadas.\
      Além dos tratamentos mencionados, a depender de como cada base de
dados se apresenta, será necessário `verticalizar` ou `matricizar` as
informações. Tal procedimento é importante para a etapa de armazenamento
dos dados já tratados, uma vez que os *outputs* são gerados de forma a
atender a necessidade de usá-los tanto para os dashboards elaborados em
Tableau quanto para as análises econômicas feitas no Matlab.

<!------------->

<!-- Parte 3 -->

<!------------->

## Diretórios *Input* e *Output*

<p>

      A pasta `Databases` contém as subpastas `Inputs` e `Outputs`. Na
primeira pasta, as planilhas de resultados vindos de outras rotinas
contendo dados mensais pré-tratados, ficam armazenadas. Já na pasta
`Outputs` são colocados os resultados gerados pelos scripts deste
repositório.

</p>
