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
| [ICMS_Dataset.R](https://github.com/paulo-icaro/Dataset_Sefaz_Estudos_Economicos/blob/main/ICMS_Dataset.R) | Sefaz-CE | Dados de Arrecadação de ICMS | Ajuste da Frequência e Correção Monetária |
| [Siof_Dataset.R](https://github.com/paulo-icaro/Dataset_Sefaz_Estudos_Economicos/blob/main/Siof_Dataset.R) | Seplag | Dados de Investimentos Públicos no Ceará | Ajuste da Frequência e Correção Monetária |
| [Siconfi_Dataset.R](https://github.com/paulo-icaro/Dataset_Sefaz_Estudos_Economicos/blob/main/Siconfi_Dataset.R) | [Siconfi](https://apidatalake.tesouro.gov.br/docs/siconfi/) | Acesso a dados dos relatórios RREO | Correção Monetária |
| [Bacen_Dataset](https://github.com/paulo-icaro/Dataset_Sefaz_Estudos_Economicos/blob/main/notas/Bacen_Dataset.md) | Banco Central ([SGS](https://www3.bcb.gov.br/sgspub/localizarseries/localizarSeries.do?method=prepararTelaLocalizarSeries)) | Acesso a variáveis macroeconômicas | Ajuste da Frequência e Correção Monetária |
| [Ipeadata_Dataset](https://github.com/paulo-icaro/Dataset_Sefaz_Estudos_Economicos/blob/main/Ipeadata_Dataset.R) | Instit. Ipea ([Ipeadata](https://www.ipeadata.gov.br/Default.aspx)) | Acesso a variáveis macroeconômicas | Ajuste da Frequência |
| [Employment Dataset](https://github.com/paulo-icaro/Dataset_Sefaz_Estudos_Economicos/blob/main/Employment_Dataset.R) | Minist. Trabalho (MTE) | Construção da série de estoque empregos estimada e salário médio | Ajuste da Frequência e Correção Monetária |

<!------------->

<!-- Parte 2 -->

<!------------->

## Tratamentos Implementados

      Apesar de distintos, os scripts possuem etapas estão presentes em
quase todos os scripts. O fato da maioria dos dados ser de frequência
mensal implica que o ajuste de frequência é necessário. Para valores
monetários, é importante reajustá-los de acordo com a inflação. Para
cada um dos procedimentos, respectivamente, as funções
[**cumulative_transform**](https://github.com/paulo-icaro/Variables_Frequency_Transforming)
e
[**value_updating**](https://github.com/paulo-icaro/Update_Variables_Actual_Value)
são aplicadas.\
      Além dos tratamentos mencionados, a depender de como cada base de
dados se apresenta, será necessário **“verticalizar”** ou
**“matricizar”** as informações. Uma base de dados **matricial** é assim
chamada quando cada coluna representa uma série temporal. Por outro
lado, uma base de dados **vertical** ocorre quando as séries temporais
passam a ser identificadas por meio de uma única coluna de nomes de
séries e os valores ficam agrupados sob uma coluna de valores.

Vejamos uma base de dados no formato **matricial**:
</p>

             data selic_acum_anual tx_cambio_mp inflação_ipca
    1  01/01/2015            11.82       2.6336          1.24
    2  01/02/2015            12.15       2.8158          1.22
    3  01/03/2015            12.58       3.1389          1.32
    4  01/04/2015            12.68       3.0426          0.71
    5  01/05/2015            13.15       3.0611          0.74
    6  01/06/2015            13.58       3.1111          0.79
    7  01/07/2015            13.69       3.2225          0.62
    8  01/08/2015            14.15       3.5137          0.22
    9  01/09/2015            14.15       3.9058          0.54
    10 01/10/2015            14.15       3.8795          0.82

<p>

A seguir temos um exemplo de uma base de dados no formato **vertical**:
</p>

    # A tibble: 10 × 3
       data       variavel         valor 
       <chr>      <chr>            <chr> 
     1 01/01/2015 selic_acum_anual 11.82 
     2 01/01/2015 tx_cambio_mp     2.6336
     3 01/01/2015 inflação_ipca    1.24  
     4 01/02/2015 selic_acum_anual 12.15 
     5 01/02/2015 tx_cambio_mp     2.8158
     6 01/02/2015 inflação_ipca    1.22  
     7 01/03/2015 selic_acum_anual 12.58 
     8 01/03/2015 tx_cambio_mp     3.1389
     9 01/03/2015 inflação_ipca    1.32  
    10 01/04/2015 selic_acum_anual 12.68 

<p>

      Tal procedimento é importante para a etapa de armazenamento dos
dados já tratados, uma vez que os *outputs* são gerados de forma a
atender a necessidade de usá-los tanto para os dashboards elaborados em
Tableau quanto para as análises econômicas feitas no Matlab.

</p>

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
