# Ipeadata Dataset (ASSET - SEFAZ CE)
Paulo Icaro
2026-11-17

<!------------->

<!-- Parte 1 -->

<!------------->

## Objetivo

<p>

      Este tutorial mostra como é realizada a extração e tratamento de
séries macroeconômicas disponíveis na
[API](https://www.ipeadata.gov.br/Default.aspx) do Instituto Ipea.

</p>

<!------------->

<!-- Parte 2 -->

<!------------->

## Bibliotecas e *Scripts* Auxiliares

<p>

      Esta rotina faz uso da bibliotecas
[openxlsx](https://cran.r-project.org/web/packages/openxlsx/index.html)
leitura/criação de arquivos Excel, respectivamente.\
      Além das bibliotecas, os seguintes *scripts* são fundamentais para
o funcionamento dessa rotina:

- [ipeadata_query](https://github.com/paulo-icaro/Ipeadata_API/blob/main/readme_pt_br.md):
  realizar consultas aos dados disponíveis na API Ipeadata;
- [cumulative_transform](https://github.com/paulo-icaro/Variables_Frequency_Transforming):
  converter a frequência de uma série de dados de acordo com a regra de
  agregação adequada.

</p>

``` r
# ============================= #
# === Bibliotecas e Scripts === #
# ============================= #
source('https://raw.githubusercontent.com/paulo-icaro/Variables_Frequency_Transforming/refs/heads/main/variables_frequency_transforming.R')
source('https://raw.githubusercontent.com/paulo-icaro/Ipeadata_API/refs/heads/main/ipeadata_query.R')
library(tidyr)
library(openxlsx)
```

<!------------->

<!-- Parte 3 -->

<!------------->

## Extração dos Dados

<p>

      Para extração dos dados, os seguintes parâmetros precisam ser
informados na função
[ipeadata_query](https://github.com/paulo-icaro/Ipeadata_API/blob/main/readme_pt_br.md):
`Código da série`, `Nome da série`, `Intervalo de Extração`.\
      Para o projeto, as seguintes séries foram coletadas:

| **Série**                                  | **Código**      |
|:-------------------------------------------|:----------------|
| Índice de Preços ao Consumido Amplo (IPCA) | PRECOS12_IPCA12 |

      É valido mencionar que procedimentos como ajuste na formatação das
datas e transformação dos valores para padrão numérico foram
implementadas no conjunto de dados. Tais correções visam garantir o
pleno funcionamento da base de dados nas etapas a seguir. Além disso,
foi acrescentado a taxa de inflação ao conjunto de dados, sendo esta
calculada com base no IPCA.

</p>

``` r
# ========================= #
# === Extracao de Dados === #
# ========================= #

# --- Informacoes Previas --- #
cod_ipeadata_series = c('PRECOS12_IPCA12')#, 'DIMAC_CF_INVBR_TOT')
name_ipeadata_series = c('ipca')#, 'inv_bruto_total')
periodo = as.character(2014:2025)
#periodo = as.character(2014:year(Sys.Date()))


# --- Extração --- #
ipeadata_dataset_m = ipeadata_query(cod_ipeadata_series, name_ipeadata_series, periodo)

# --- Ajuste na Data --- #
ipeadata_dataset_m = ipeadata_dataset_m %>% mutate(data = as.Date(data))

# --- Ajuste na Série de Preços --- #
ipeadata_dataset_m$ipca = (ipeadata_dataset_m$ipca/last(ipeadata_dataset_m$ipca))*100
ipeadata_dataset_m = ipeadata_dataset_m %>% mutate('ipca_%' = (ipca/lag(ipca) - 1)*100)
ipeadata_dataset_m = ipeadata_dataset_m %>% filter(substr(data, 1, 4) != '2014')
```

<!------------->

<!-- Parte 4 -->

<!------------->

## Processamento de Dados

<p>

      Os dados extraídos já estão na forma **matricial**. Além disso, os
seguintes procedimentos são adotados no refinamento da base de dados:

- **Conversão de frequência**: os valores que inicialmente tinham
  frequência mensal foram devidamente bimestralizados;
- **Verticalização da base de dados**: os dados passam pelo processo de
  “verticalização” para atender aos padrões do Tableau.

      No processo de “bimestralização” da base de dados, as regras de
conversão aplicadas foram as seguintes:

| **Série**     | **Código**     |
|:--------------|:---------------|
| IPCA - Índice | Período Final  |
| IPCA - Taxa   | Taxa Acumulada |

``` r
# ============================== #
# === Processamento de Dados === #
# ============================== #

# ------------------------------------------- #
# -- Tranformacao da Frequencia dos Dados --- #
# ------------------------------------------- #
#ipeadata_dataset_bimonthly_sum = cumulative_transform('soma', 'bimestral', ipeadata_dataset[c(1,3)])
ipeadata_dataset_bimonthly_end_m = cumulative_transform('periodo_final', 'bimestral', ipeadata_dataset_m[c(1,2)])
ipeadata_dataset_bimonthly_cum_m = cumulative_transform('tx_acumulada', 'bimestral', ipeadata_dataset_m[c(1,3)])
ipeadata_dataset_bimonthly_m = left_join(x = ipeadata_dataset_bimonthly_end_m, y = ipeadata_dataset_bimonthly_cum_m, by = 'data')



# ------------------------------- #
# --- Verticalizando os Dados --- #
# ------------------------------- #
ipeadata_dataset_t = pivot_longer(data = ipeadata_dataset_m, cols = !starts_with('data'), names_to = 'variavel', values_to = 'valor')
ipeadata_dataset_bimonthly_t = pivot_longer(data = ipeadata_dataset_bimonthly_m, cols = !starts_with('data'), names_to = 'variavel', values_to = 'valor')
```

<p>

      A execução da rotina irá gerar *outputs* para ambos os padrões de
dados. Padrão Tableau:

</p>

             data     ipca    ipca_%
    1  2015-01-01 55.51856 1.2399442
    2  2015-02-01 56.19583 1.2198920
    3  2015-03-01 56.93766 1.3200844
    4  2015-04-01 57.34194 0.7100392
    5  2015-05-01 57.76621 0.7398962
    6  2015-06-01 58.22263 0.7901136
    7  2015-07-01 58.58355 0.6198975
    8  2015-08-01 58.71241 0.2199621
    9  2015-09-01 59.02943 0.5399561
    10 2015-10-01 59.51341 0.8198860

<p>

e padrão Matlab:
</p>

             data     ipca    ipca_%
    1  2015-01-01 55.51856 1.2399442
    2  2015-02-01 56.19583 1.2198920
    3  2015-03-01 56.93766 1.3200844
    4  2015-04-01 57.34194 0.7100392
    5  2015-05-01 57.76621 0.7398962
    6  2015-06-01 58.22263 0.7901136
    7  2015-07-01 58.58355 0.6198975
    8  2015-08-01 58.71241 0.2199621
    9  2015-09-01 59.02943 0.5399561
    10 2015-10-01 59.51341 0.8198860

<!------------->

<!-- Parte 5 -->

<!------------->

## Armazenamento

<p>

      Os resultados gerados são armazenados em dois diretórios
distintos. Considerando o caminho base do diretório de armazenamento
`Databases/Outputs/`, os resultados podem ser armazenados nas pastas
*Tableau* ou *Matlab* a depender do padrão do *output* gerado. Assim,
para essa rotina, os *paths* de armazenamento serão
`Databases/Outputs/Tableau` e `Databases/Outputs/Matlab`.\
      Alguns itens são pré-definidos visado padronizar o armazenamento
dos resultados nessa e em outras rotinas. Duas listas são criadas:
**aba** e **dataframe**. Essas listas representam onde e quais dados
serão armazenados. Essa parte é “editável” no script, sendo possível
alternar de modo a atender ao que se deseja armazenar.\
      Na etapa de armazenamento vale atentar que há uma distinção para o
*output* gerado para Matlab. Uma aba adicional, nomeada **tempo** é
acrescentada tendo em vista a necessidade das datas serem especificadas
em padrão numérico[^1] necessário ao software.

</p>

``` r
# ==================================== #
# === Armazenamento dos Resultados === #
# ==================================== #

# --- Pre Definicoes --- #
save_path = c('Databases/Outputs/Tableau/db_ipeadata_tableau', 'Databases/Outputs/Matlab/db_ipeadata_matlab')
formato = c('tableau', 'matlab')
aba = c('ipeadata_bimestre', 'ipeadata_original')
dataframe = list(
  tableau = list(ipeadata_dataset_bimonthly_t, ipeadata_dataset_t),
  matlab = list( ipeadata_dataset_bimonthly_m, ipeadata_dataset_m)
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
    writeData(wb = wb, sheet = 'tempo', as.numeric(ipeadata_dataset_m$data) + 25569, rowNames = FALSE)
  }
  saveWorkbook(wb = wb, file = paste0(save_path[f], '.xlsx'), overwrite = TRUE)
}
```

[^1]: O ajuste da data ao padrão numérico envolve a soma da coluna data
    do conjunto de dados com o número 25569. Esse último representa a
    data 01/01/1970, que é a data-início do calendário no R.
