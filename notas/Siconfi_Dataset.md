# Siconfi Dataset
Paulo Icaro
2026-11-11

<!------------->

<!-- Parte 1 -->

<!------------->

## Objetivo

<p>

      Este tutorial mostra como é realizada a extração e tratamento das
variáveis disponíveis na
[API](https://apidatalake.tesouro.gov.br/docs/siconfi/) do Siconfi.

</p>

<!------------->

<!-- Parte 2 -->

<!------------->

## Bibliotecas e *Scripts* Auxiliares

<p>

      Esta rotina faz uso das bibliotecas
[tidyr](https://tidyr.tidyverse.org/) e
[dplyr](https://dplyr.tidyverse.org/) para manipulações na base de
dados, [stringr](https://stringr.tidyverse.org/) para manipulação
textual, [readxl](https://readxl.tidyverse.org/) e
[openxlsx](https://cran.r-project.org/web/packages/openxlsx/index.html)
para modelagem de conjunto de dados e leitura/criação de arquivos
Excel.\
      Além das bibliotecas, os seguintes *scripts* são essenciais no
funcionamento dessa rotina?

- [siconfi_rreo_query]('https://raw.githubusercontent.com/paulo-icaro/Siconfi_API'):
  realizar consultas aos dados disponíveis na API do Siconfi;
- [value_updating](https://github.com/paulo-icaro/Update_Variables_Actual_Value):
  atualizar valores monetários para o período desejado.

</p>

``` r
# ----------------------------- #
# --- Bibliotecas e Scripts --- #
# ----------------------------- #
library(tidyr)
library(dplyr)
library(stringr)
library(readxl)
library(openxlsx)
source('https://raw.githubusercontent.com/paulo-icaro/Siconfi_API/refs/heads/main/siconfi_rreo_query.R')
source('https://raw.githubusercontent.com/paulo-icaro/Update_Variables_Actual_Value/refs/heads/main/update_actual_value.R')


# Obs: Importação manual, caso a linha acima não funcione. Lembre-se de trocar para o seu diretório.
# source('C://Users/Paulo/Documents/Repositorios/Siconfi_API/Query_RREO.R')
# source('C://Users/Paulo/Documents/Repositorios/Siconfi_API/API_Siconfi.R')
# source('C://Users/Paulo/Documents/Repositorios/Siconfi_API/FG_URL_RREO.R')
```

<!------------->

<!-- Parte 3 -->

<!------------->

## Extração dos Dados

<p>

      Para executar a extração dos dados, é necessário informar a função
[siconfi_rreo_query]('https://raw.githubusercontent.com/paulo-icaro/Siconfi_API')
os seguintes parâmetros:

- `ano`: intervalo de anos que se deseja extrair os dados;
- `periodo`: intervalo de bimestres desejado
- `tipo_demonstrativo`: basta informar RREO uma vez que todos os dados
  necessários dessa fonte vem deste relatório;
- `relatorio`: codigo dos relatorios disponíveis no RREO;
- `esfera`: o nível governamental referente aos dados extraídos (ex:
  estadual)
- `ente`: código referente ao ente federativo desejado (ex: Ceará = 23,
  Fortaleza = 2304400);

      Para os objetivos do projeto, foram acessados dados de caráter
estadual e municipal. Além disso, pequenos ajustes foram implementados
entre a extrações. Considerando que a base de dados contempla
inicialmente o intervalo 2015-2025, uma extração de dados municipais do
Ceará levaria bastante tempo para ser concluída. Para fins de exibição,
esse intervalo foi reduzido para o ano de 2025.

</p>

``` r
# ========================= #
# === Extração de Dados === #
# ========================= #

# --- Informações Prévias --- #
ano = 2015:2025
bimestre = 1:6
tipo_demonstrativo = 'RREO'
#state_municipalities = read_excel(path = 'Databases/Inputs/Lista_Municipios_Brasil.xlsx', sheet = 'Ceara')

# --- Extracao --- #
siconfi_dataset_est = siconfi_rreo_query(ano, bimestre, tipo_demonstrativo, c('01', '04', '06'), 'E', 23, TRUE)
siconfi_dataset_mun = siconfi_rreo_query(2025:2025, bimestre, tipo_demonstrativo, c('01'), 'M', state_municipalities$`Cod. 7 Digitos`, TRUE)
```

<p>

Vejamos um recorte dos dados acessados:
</p>

          exercicio demonstrativo periodo         anexo esfera rotulo
    59563      2025          RREO       6 RREO-Anexo 06      E Padrão
    59564      2025          RREO       6 RREO-Anexo 06      E Padrão
    59565      2025          RREO       6 RREO-Anexo 06      E Padrão
    59566      2025          RREO       6 RREO-Anexo 06      E Padrão
    59567      2025          RREO       6 RREO-Anexo 06      E Padrão
    59568      2025          RREO       6 RREO-Anexo 06      E Padrão
    59569      2025          RREO       6 RREO-Anexo 06      E Padrão
    59570      2025          RREO       6 RREO-Anexo 06      E Padrão
    59571      2025          RREO       6 RREO-Anexo 06      E Padrão
    59572      2025          RREO       6 RREO-Anexo 06      E Padrão

<p>

Note que para a extração dos dados municipais foi necessário acessar uma
planilha auxiliar[^1], Lista_Municipios_Brasil.xlsx, contendo toda a
lista de múnicipios do estado.
</p>

<!------------->

<!-- Parte 4 -->

<!------------->

## Seleção dos Dados

### Filtros Gerais

<p>

      Das variáveis escolhidas para compor o conjunto de informações do
Siconfi, estão:

- Resultado Previdenciário Bruto
- Dívida Consolidada Líquida Bruta
- Resultado Primário Bruto
- Investimento Municipal Bruto

      Cada uma dessas variáveis possuem filtros devidamente aplicados
para chegar nos valores iniciais, como pode ser visto a seguir.

</p>

``` r
# ---------------------- #
# --- Filtros Gerais --- #
# ---------------------- #

# --- Resultado Previdenciário --- #
resultado_previdenciario_bruto = ajuste_data_siconfi(siconfi_dataset_est[c(1, 3, 9, 12, 13, 14, 15)]) %>%
  filter(str_detect(conta, 'RESULTADO PREVIDENCIÁRIO'), str_detect(anexo, '04'))

# --- Dívida Consolidada Líquida --- #
divida_consolidada_liquida_bruto = ajuste_data_siconfi(siconfi_dataset_est[c(1, 3, 9, 12, 13, 14, 15)]) %>%
  filter(str_detect(conta, 'DÍVIDA CONSOLIDADA LÍQUIDA'), str_detect(anexo, '06'))

# --- Resultado Primário --- #
resultado_primario_bruto = ajuste_data_siconfi(siconfi_dataset_est[c(1, 3, 9, 12, 13, 14, 15)]) %>%
  filter(str_detect(conta, 'RESULTADO PRIMÁRIO'), str_detect(anexo, '06'))

# --- Investimento Municipal --- #
investimento_municipal_bruto = ajuste_data_siconfi(siconfi_dataset_mun[c(1, 3, 5, 9, 12, 13, 14, 15)]) %>%
  filter(str_detect(conta, 'INVESTIMENTOS'), str_detect(anexo, '01'))
```

<p>

      É importante destacar a utilidade da função
**ajuste_data_siconfi** criada especificamente para aplicar os ajustes
no padrão de datas da base extraída.

</p>

``` r
ajuste_data_siconfi = function(base){
  
  base = base %>%
    mutate(data = 
             as.Date(paste0(exercicio,
                    case_when(periodo == 1 ~ '-02-01', 
                              periodo == 2 ~ '-04-01',
                              periodo == 3 ~ '-06-01',
                              periodo == 4 ~ '-08-01',
                              periodo == 5 ~ '-10-01',
                              .default = '-12-01')), format = '%Y-%m-%d'))
  return(base)
}
```

### Filtros Específicos

<p>

      Feitos os filtros iniciais, é hora de definir melhor a busca pelas
rubricas desejadas. Nessa parte não há um padrão de seleção a ser
seguido, dado que as rubricas não possuem a nomenclatura padronizada e
que podem mudar de ano para ano. Contudo, vale a pena atentar em **um
ponto que elas tem em comum: o tipo da conta**. Na grande maioria dos
casos foi considerada a rubrica genérica **Despesas pagas até o
bimestre**. Vejamos:

</p>

``` r
# --------------------------- #
# --- Filtros Especificos --- #
# --------------------------- #

# --- Resultado Previdenciário Pago (Acumulado do Bimestre) --- #
resultado_previdenciario =
  resultado_previdenciario_bruto %>%
  filter(conta %in% c('RESULTADO PREVIDENCIÁRIO - FUNDO EM REPARTIÇÃO (XI) = (IX ¿ X)'),
         str_detect(coluna, 'DESPESAS PAGAS ATÉ O BIMESTRE')) %>%
  mutate('res_prev' = ifelse(periodo == 1, valor, valor - lag(valor)))

# --- Dívida Consolidada Líquida (Até o Bimestre) --- #
divida_consolidada_liquida =
  divida_consolidada_liquida_bruto %>%
  filter(conta %in% c('DÍVIDA CONSOLIDADA LÍQUIDA (XXXI) = (XXVIII - XXIX)',
                      'DÍVIDA CONSOLIDADA LÍQUIDA (XLII) = (XXXIX - XL)') & str_detect(coluna, 'Até o Bimestre'))
colnames(divida_consolidada_liquida)[7] = 'div_cons'

# --- Resultado Primário (Acumulado no Ano) --- #
resultado_primario =
  resultado_primario_bruto %>%
  filter(conta %in% c('RESULTADO PRIMÁRIO (SEM RPPS) - Acima da Linha (XXXV) = (XVIIa - (XXXIIIa +XXXIIIb + XXXIIIc))'),
         str_detect(coluna, regex('VALOR'))) %>%
  mutate('res_prim' = ifelse(periodo == 1, valor, valor - lag(valor)))

# --- Investimento Municipal --- # 
investimento_municipal =
  investimento_municipal_bruto %>%
  filter(conta %in% c('INVESTIMENTOS'),
         str_detect(coluna, 'DESPESAS PAGAS ATÉ O BIMESTRE')) %>%
  group_by(data) %>%
  select(data, exercicio, periodo, valor) %>%
  summarize('inv_mun_acum' = sum(valor)) %>%
  mutate('inv_mun' = ifelse(substr(data, 6, 6) == 1, inv_mun_acum, inv_mun_acum - lag(inv_mun_acum)))
```

    # A tibble: 6 × 3
      data       inv_mun_acum     inv_mun
      <date>            <dbl>       <dbl>
    1 2025-02-01   204395716.         NA 
    2 2025-04-01   536075328.  331679612.
    3 2025-06-01   997896764.  461821436.
    4 2025-08-01  1636900150.  639003386.
    5 2025-10-01  2388624669. 2388624669.
    6 2025-12-01  3411530716. 3411530716.

<!------------->

<!-- Parte 4 -->

<!------------->

## Processamento de Dados

<p>

      Extraído as informações, estas já estão na forma matricial. Além
disso, deve-se lembrar que os dados já são bimestrais, dispensando
qualquer ajuste de frequência. Dito isto, os seguintes procedimentos
foram realizados nos dados:

- **Junção das bases**: por através de técnicas de *join*, as bases
  foram todas combinadas;
- **Atualização dos valores monetários**: todos os valores monetários
  foram atualizados para o período 2025/12;
- **Concatenação da base em termos reais e nominais**: as bases reais e
  nominais foram combinadas, tendo agora uma variável categórica
  indicado se está sendo usado valor real ou nominal;
- **Verticalização da base de dados**: os dados passam pelo processo de
  “verticalização” para atender aos padrões do Tableau.

</p>

``` r
# ============================== #
# === Processamento de Dados === #
# ============================== #

# ------------------------ #
# --- Unindo Variaveis --- #
# ------------------------ #
# Obs: Ajuste de acordo com o maior dataframe
siconfi_macro_bimonthly_curr_m = 
  divida_consolidada_liquida[c('data', 'div_cons')] %>%
  left_join(y = resultado_previdenciario[c('data', 'res_prev')], by = 'data') %>%
  left_join(y = resultado_primario[c('data', 'res_prim')], by = 'data') %>%
  left_join(y = investimento_municipal[c('data', 'inv_mun')], by = 'data') %>%
  mutate(res_prim_prev = res_prev + res_prim)

# ----------------------------------------- #
# --- Atualizacao de Valores Monetarios --- #
# ----------------------------------------- #
siconfi_macro_bimonthly_actual_m = value_updating(series = siconfi_macro_bimonthly_curr_m, variables = colnames(select(siconfi_macro_bimonthly_curr_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)

# --------------------------------------------- #
# --- Base Final - Valores Nominais e Reais --- #
# --------------------------------------------- #
siconfi_macro_bimonthly_m = rbind(siconfi_macro_bimonthly_curr_m |> mutate(tipo_preco = 'nominal'), siconfi_macro_bimonthly_actual_m |> mutate(tipo_preco = 'real'))

# ------------------------------- #
# --- Verticalizando os Dados --- #
# ------------------------------- #
siconfi_macro_bimonthly_t = pivot_longer(data = siconfi_macro_bimonthly_m, cols = !starts_with(c('data', 'tipo_preco')), names_to = 'variavel', values_to = 'valor')
```

<p>

      A execução da rotina irá, portanto, gerar *outputs* para ambos os
padrões de dados. Padrão Tableau:

</p>

    # A tibble: 10 × 4
       data       tipo_preco variavel             valor
       <date>     <chr>      <chr>                <dbl>
     1 2025-10-01 real       div_cons      10337055884.
     2 2025-10-01 real       res_prev       -218454715.
     3 2025-10-01 real       res_prim       -729969430.
     4 2025-10-01 real       inv_mun        2400821258.
     5 2025-10-01 real       res_prim_prev  -948424145.
     6 2025-12-01 real       div_cons      11968573704.
     7 2025-12-01 real       res_prev       -192123618.
     8 2025-12-01 real       res_prim       -965501588.
     9 2025-12-01 real       inv_mun        3411530716.
    10 2025-12-01 real       res_prim_prev -1157625206.

<p>

e padrão Matlab:
</p>

    # A tibble: 10 × 4
       data       tipo_preco variavel             valor
       <date>     <chr>      <chr>                <dbl>
     1 2025-10-01 real       div_cons      10337055884.
     2 2025-10-01 real       res_prev       -218454715.
     3 2025-10-01 real       res_prim       -729969430.
     4 2025-10-01 real       inv_mun        2400821258.
     5 2025-10-01 real       res_prim_prev  -948424145.
     6 2025-12-01 real       div_cons      11968573704.
     7 2025-12-01 real       res_prev       -192123618.
     8 2025-12-01 real       res_prim       -965501588.
     9 2025-12-01 real       inv_mun        3411530716.
    10 2025-12-01 real       res_prim_prev -1157625206.

<!------------->

<!-- Parte 5 -->

<!------------->

## Armazenamento

<p>

      Os resultados gerados são armazenados em dois diretórios
distintos. Considerando o caminho base do diretório de armazenamento
`Databases/Outputs/`, os resultados podem ser armazenados nas pastas
*Tableau* ou *Matlab* a depender do padrão do *output* gerado.\
      Assim, para essa rotina, os *paths* de armazenamento serão
`Databases/Outputs/Tableau` e `Databases/Outputs/Matlab`.

</p>

``` r
# ==================================== #
# === Armazenamento dos Resultados === #
# ==================================== #

# --- Pre Definicoes --- #
save_path = c('Databases/Outputs/Tableau/db_siconfi_tableau', 'Databases/Outputs/Matlab/db_siconfi_matlab')
formato = c('tableau', 'matlab')
aba = c('siconfi_macro')
dataframe = list(
  tableau = list(siconfi_macro_bimonthly_t),
  matlab = list(siconfi_macro_bimonthly_m)
)

# --- Armazenamento --- #
for(f in seq_along(formato)){
  wb = createWorkbook(creator = 'Sefaz-CE')
  for(s in seq_along(aba)){
    addWorksheet(wb = wb, sheetName = aba[s])
    writeData(wb = wb, sheet = aba[s], x = as.data.frame(dataframe[[f]][s]), rowNames = FALSE, colNames = TRUE)
  }
  if(formato[f] == 'matlab'){
    addWorksheet(wb = wb, sheetName = 'tempo')
    writeData(wb = wb, sheet = 'tempo', as.numeric(siconfi_macro_bimonthly_m$data) + 25569, rowNames = FALSE)
  }
  saveWorkbook(wb = wb, file = paste0(save_path[f], '.xlsx'), overwrite = TRUE)
}
```

[^1]: O trecho de leitura da planilha foi colocado como um comentário em
    razão da maneira como essa documentação foi montada. No entanto ao
    executar em sua máquina, basta remover o comentário e tudo
    funcionará normalmente.
