# Gene Expression Explore

## Overview

This page focuses on expression-layer retrieval workflows after metadata
filtering.

``` r

library(cellNexus)
library(dplyr)

metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"])
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/cellnexus_sample_metadata.2.3.0.parquet to /vast/scratch/users/shen.m/r_cache/R/cellNexus/cellnexus_sample_metadata.2.3.0.parquet
metadata <- metadata |>
  keep_quality_cells()
```

``` python
from cellnexuspy import get_metadata, keep_quality_cells, get_anndata, get_pseudobulk, SAMPLE_DATABASE_URL

conn, metadata = get_metadata(SAMPLE_DATABASE_URL)
#> File is missing or corrupted. Re-downloading...
#> Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/cellnexus_sample_metadata.2.3.0.parquet to /home/juan/.cache/cellNexusPy/cellnexus_sample_metadata.2.3.0.parquet
#> 1.65MB [00:05, 321kB/s]933 [00:00<?, ?it/s]
#>   0%|          | 0/1724933 [00:05<?, ?it/s]

metadata = keep_quality_cells(metadata)
```

## Choose cells through metadata filters

``` r

query_metadata <- metadata |>
  dplyr::filter(
    age_days >= 40*365,
    cell_type_unified_ensemble == "cd16 mono",
    tissue_groups == "breast",
    imputed_ethnicity == "African American"
  )
query_metadata  
#> # Source:   SQL [?? x 58]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.112.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id observation_joinid dataset_id                       sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups
#>      <dbl> <chr>              <chr>                            <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>        
#>  1      16 j}0<Y>a#X~         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  2      19 lNmuO5xs~3         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  3      14 qxl7HJjL$L         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  4       2 $jvBt8wHSK         842c6f5d-4a94-4eef-8510-8c792d1… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast       
#>  5      21 Mq^|(c<-#3         842c6f5d-4a94-4eef-8510-8c792d1… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast       
#>  6      24 I`4{4__f#J         842c6f5d-4a94-4eef-8510-8c792d1… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast       
#>  7      22 %vkLP;!cqY         842c6f5d-4a94-4eef-8510-8c792d1… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast       
#>  8      11 gncTL3)pV~         842c6f5d-4a94-4eef-8510-8c792d1… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast       
#>  9      25 rfOnkhfWl8         842c6f5d-4a94-4eef-8510-8c792d1… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast       
#> 10      24 =tj7A<!2TZ         842c6f5d-4a94-4eef-8510-8c792d1… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast       
#> 11      13 Py{Fqs?~!!         842c6f5d-4a94-4eef-8510-8c792d1… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast       
#> 12       9 s$u5u14ye$         842c6f5d-4a94-4eef-8510-8c792d1… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast       
#> 13       6 ?y4kdGGQ!^         842c6f5d-4a94-4eef-8510-8c792d1… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast       
#> # ℹ 48 more variables: nFeature_expressed_in_sample <int>, nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>,
#> #   subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>,
#> #   count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>,
#> #   .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, published_at <chr>, raw_data_location <chr>, revised_at <chr>, primary_cell_count <chr>, schema_version <chr>, …
```

``` python
query_metadata = metadata.filter("""
    age_days >= 40*365
    AND cell_type_unified_ensemble == 'cd16 mono'
    AND tissue_groups == 'breast'
    AND imputed_ethnicity == 'African American'
""")
query_metadata
#> ┌─────────┬────────────────────┬──────────────────────────────────────┬──────────────────────────────────┬──────────────────────────────────┬───────────────┬──────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬──────────┬───────────────┬──────────────────────────────┬────────────────────┬───────────────┬────────────────────────────┬───────────┬──────────────────────┬──────────────────────┬────────────────────┬───────────────┬───────────────────┬──────────────┬────────────┬─────────────────────────┬───────────────────────────────────────────┬───────────────────────────────────────────┬───────────────────┬───────────────────────────┬───────────────────┬─────────┬───────────────────────────────────┬────────────────────────────────┬────────────────────────────┬──────────────────────────┬──────────────────────────┬───────────────────┬───────────────────┬──────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬──────────────────────────────────────┬──────────────────────────────────────┬───────────────────┬──────────────┬───────────────────┬────────────┬────────────────────┬────────────────┬─────────────┬────────────────────────────┬───────────┬────────────────────────────┬──────────────────────────────────────────────────────────────────────────────┬────────────┬───────────────┬──────────────┬──────────┬─────────────────────┬─────────────────┬─────────────────────────────────────────────────────────────────────────────────────┐
#> │ cell_id │ observation_joinid │              dataset_id              │            sample_id             │             sample_              │ experiment___ │ run_from_cell_id │                                                                                 sample_heuristic                                                                                 │ age_days │ tissue_groups │ nFeature_expressed_in_sample │     nCount_RNA     │ empty_droplet │ cell_type_unified_ensemble │ is_immune │ subsets_Mito_percent │ subsets_Ribo_percent │ high_mitochondrion │ high_ribosome │ scDblFinder.class │ sample_chunk │ cell_chunk │ sample_pseudobulk_chunk │       file_id_cellNexus_single_cell       │       file_id_cellNexus_pseudobulk        │ count_upper_bound │ nfeature_expressed_thresh │ inverse_transform │  alive  │ cell_annotation_blueprint_singler │ cell_annotation_monaco_singler │ cell_annotation_azimuth_l2 │ ethnicity_flagging_score │ low_confidence_ethnicity │ .aggregated_cells │ imputed_ethnicity │       atlas_id       │                                                                                                                                                    citation                                                                                                                                                    │            collection_id             │          dataset_version_id          │ default_embedding │ published_at │ raw_data_location │ revised_at │ primary_cell_count │ schema_version │ tissue_type │           title            │ tombstone │ x_approximate_distribution │                                 explorer_url                                 │ cell_count │ feature_count │   filesize   │ filetype │ mean_genes_per_cell │ suspension_type │                                         url                                         │
#> │ double  │      varchar       │               varchar                │             varchar              │             varchar              │    varchar    │     varchar      │                                                                                     varchar                                                                                      │  int32   │    varchar    │            int32             │       double       │    boolean    │          varchar           │  boolean  │        int32         │        int32         │      boolean       │    boolean    │      varchar      │    int32     │   int32    │          int32          │                  varchar                  │                  varchar                  │      double       │          double           │      varchar      │ boolean │              varchar              │            varchar             │          varchar           │          double          │         varchar          │       int32       │      varchar      │       varchar        │                                                                                                                                                    varchar                                                                                                                                                     │               varchar                │               varchar                │      varchar      │   varchar    │      varchar      │  varchar   │      varchar       │    varchar     │   varchar   │          varchar           │  boolean  │          varchar           │                                   varchar                                    │   int32    │     int32     │    double    │ varchar  │       double        │     varchar     │                                       varchar                                       │
#> ├─────────┼────────────────────┼──────────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────┼───────────────┼──────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼──────────┼───────────────┼──────────────────────────────┼────────────────────┼───────────────┼────────────────────────────┼───────────┼──────────────────────┼──────────────────────┼────────────────────┼───────────────┼───────────────────┼──────────────┼────────────┼─────────────────────────┼───────────────────────────────────────────┼───────────────────────────────────────────┼───────────────────┼───────────────────────────┼───────────────────┼─────────┼───────────────────────────────────┼────────────────────────────────┼────────────────────────────┼──────────────────────────┼──────────────────────────┼───────────────────┼───────────────────┼──────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼──────────────────────────────────────┼───────────────────┼──────────────┼───────────────────┼────────────┼────────────────────┼────────────────┼─────────────┼────────────────────────────┼───────────┼────────────────────────────┼──────────────────────────────────────────────────────────────────────────────┼────────────┼───────────────┼──────────────┼──────────┼─────────────────────┼─────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
#> │    16.0 │ j}0<Y>a#X~         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 1119f4825edbcfb74341b89d9dec4ac8 │ 1119f4825edbcfb74341b89d9dec4ac8 │               │ NULL             │ 182a61cc-b041-4c9b-bf33-1d065115274d___P89___97daa149-e8a1-4873-8d57-7a3940fdab54___6753382c-8086-4e5f-8b53-a481720b2fa0___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         2438 │  7508.926150000006 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 3 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    19.0 │ lNmuO5xs~3         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 1119f4825edbcfb74341b89d9dec4ac8 │ 1119f4825edbcfb74341b89d9dec4ac8 │               │ NULL             │ 182a61cc-b041-4c9b-bf33-1d065115274d___P89___97daa149-e8a1-4873-8d57-7a3940fdab54___6753382c-8086-4e5f-8b53-a481720b2fa0___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1876 │  7017.710589999993 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 3 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    14.0 │ qxl7HJjL$L         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 1119f4825edbcfb74341b89d9dec4ac8 │ 1119f4825edbcfb74341b89d9dec4ac8 │               │ NULL             │ 182a61cc-b041-4c9b-bf33-1d065115274d___P89___97daa149-e8a1-4873-8d57-7a3940fdab54___6753382c-8086-4e5f-8b53-a481720b2fa0___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1547 │  7928.722270000016 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 3 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │     2.0 │ $jvBt8wHSK         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 1f755b9b59313f6c5e80caa696799ac2 │ 1f755b9b59313f6c5e80caa696799ac2 │               │ NULL             │ 9ca47fe5-873e-4d1e-98e4-68884865f41a___P66___452d2f53-2206-44a1-a288-0025c82a27bb___01b59611-b3c3-4fd4-84db-cdf9ca7aa37c___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1342 │  6663.413549999989 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ Platelet                   │                      1.0 │ FALSE                    │                 1 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    21.0 │ Mq^|(c<-#3         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ b0d0c16edf3fcbb1b0923889f1640f2d │ b0d0c16edf3fcbb1b0923889f1640f2d │               │ NULL             │ 0033e380-cba5-49d3-b27f-a4133aaf7caf___P92___ff1bbc9c-b7a2-43cf-afd0-898d60172b47___aabdb859-e43d-4d1e-94dc-d46f61d5149a___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1552 │   7366.77443000001 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 3 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    24.0 │ I`4{4__f#J         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ b0d0c16edf3fcbb1b0923889f1640f2d │ b0d0c16edf3fcbb1b0923889f1640f2d │               │ NULL             │ 0033e380-cba5-49d3-b27f-a4133aaf7caf___P92___ff1bbc9c-b7a2-43cf-afd0-898d60172b47___aabdb859-e43d-4d1e-94dc-d46f61d5149a___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1800 │  7649.221309999987 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 3 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    22.0 │ %vkLP;!cqY         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ b0d0c16edf3fcbb1b0923889f1640f2d │ b0d0c16edf3fcbb1b0923889f1640f2d │               │ NULL             │ 0033e380-cba5-49d3-b27f-a4133aaf7caf___P92___ff1bbc9c-b7a2-43cf-afd0-898d60172b47___aabdb859-e43d-4d1e-94dc-d46f61d5149a___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1759 │ 7819.2406500000025 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 3 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    11.0 │ gncTL3)pV~         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ bd5f6876c65bbc0a1c3f27b5c19520b0 │ bd5f6876c65bbc0a1c3f27b5c19520b0 │               │ NULL             │ c5d33ad8-c134-4d74-9d75-c0e9f5ab12d6___P83___70270fa5-851b-4603-8f01-63ece285a386___de239d3d-0552-48c1-a193-568d6582400f___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                          399 │ 7873.9017600000025 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          6 │                       1 │ 001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 1 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    25.0 │ rfOnkhfWl8         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 04e410cbab17c7d05877161100a5d1e1 │ 04e410cbab17c7d05877161100a5d1e1 │               │ NULL             │ 68150f23-cfed-4dca-96e0-1d59260008bd___P101___6e0d41f4-1a99-40fa-8865-adb7f59059a3___70eaee84-94e3-4dd3-968e-32fc8d742c9b___breast___mature stage___10x 3' v3______normal___TRUE │    14600 │ breast        │                         1324 │  6640.145619999993 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          7 │                       1 │ 4a469d94fef0b1c60027fad9eb660b42___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 2 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    24.0 │ =tj7A<!2TZ         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 04e410cbab17c7d05877161100a5d1e1 │ 04e410cbab17c7d05877161100a5d1e1 │               │ NULL             │ 68150f23-cfed-4dca-96e0-1d59260008bd___P101___6e0d41f4-1a99-40fa-8865-adb7f59059a3___70eaee84-94e3-4dd3-968e-32fc8d742c9b___breast___mature stage___10x 3' v3______normal___TRUE │    14600 │ breast        │                         1254 │  7388.920140000002 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          7 │                       1 │ 4a469d94fef0b1c60027fad9eb660b42___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 2 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │    13.0 │ Py{Fqs?~!!         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 30ea4b4f8922b4a6b35bf1a12be2d5e9 │ 30ea4b4f8922b4a6b35bf1a12be2d5e9 │               │ NULL             │ 2f6cb696-f78d-4438-a2ad-e9869922a206___P87___a748c9d9-f797-45b9-b879-30792ba02b58___d7f4c04a-69ed-442a-98a1-88555cdfd104___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1368 │  7811.435809999989 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          7 │                       1 │ 4a469d94fef0b1c60027fad9eb660b42___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │                      1.0 │ FALSE                    │                 1 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │     9.0 │ s$u5u14ye$         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 49ef9551c2ddf79b01c74f863ea6f556 │ 49ef9551c2ddf79b01c74f863ea6f556 │               │ NULL             │ 6fa99d77-112d-454a-8207-9fb2869ebc08___P80___cd686124-c0fa-45dd-b6ca-c5095bedc9d0___f8bc66f3-79ef-4223-a6f6-31eb640206a7___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1767 │  7780.737670000004 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          7 │                       1 │ 4a469d94fef0b1c60027fad9eb660b42___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │       0.9444444444444444 │ FALSE                    │                 2 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> │     6.0 │ ?y4kdGGQ!^         │ 842c6f5d-4a94-4eef-8510-8c792d1124bc │ 49ef9551c2ddf79b01c74f863ea6f556 │ 49ef9551c2ddf79b01c74f863ea6f556 │               │ NULL             │ 6fa99d77-112d-454a-8207-9fb2869ebc08___P80___cd686124-c0fa-45dd-b6ca-c5095bedc9d0___f8bc66f3-79ef-4223-a6f6-31eb640206a7___breast___mature stage___10x 3' v3______normal___TRUE  │    14600 │ breast        │                         1771 │   7501.68829999998 │ false         │ cd16 mono                  │ true      │                    0 │                    0 │ false              │ false         │ singlet           │            1 │          7 │                       1 │ 4a469d94fef0b1c60027fad9eb660b42___1.h5ad │ 91acbf94110b95b1e994fdb1e1322fd1___1.h5ad │              20.0 │                     200.0 │ exp               │ true    │ Monocytes                         │ Non classical monocytes        │ HSPC                       │       0.9444444444444444 │ FALSE                    │                 2 │ African American  │ cellxgene_2024/0.2.1 │ Publication: https://doi.org/10.1038/s41586-023-06252-9 Dataset Version: https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad curated and distributed by CZ CELLxGENE Discover in Collection: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731 │ 4195ab4c-20bd-4cd3-8b3d-65601277e731 │ b8b5be07-061b-4390-af0a-f9ced877a068 │ X_umap            │ 2023-05-09   │ raw.X             │ 2024-06-11 │ 714331             │ 5.1.0          │ tissue      │ scRNA-seq data - all cells │ false     │ NULL                       │ https://cellxgene.cziscience.com/e/842c6f5d-4a94-4eef-8510-8c792d1124bc.cxg/ │     714331 │         33145 │ 6913908095.0 │ H5AD     │   1987.189890960913 │ cell            │ https://datasets.cellxgene.cziscience.com/b8b5be07-061b-4390-af0a-f9ced877a068.h5ad │
#> └─────────┴────────────────────┴──────────────────────────────────────┴──────────────────────────────────┴──────────────────────────────────┴───────────────┴──────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴──────────┴───────────────┴──────────────────────────────┴────────────────────┴───────────────┴────────────────────────────┴───────────┴──────────────────────┴──────────────────────┴────────────────────┴───────────────┴───────────────────┴──────────────┴────────────┴─────────────────────────┴───────────────────────────────────────────┴───────────────────────────────────────────┴───────────────────┴───────────────────────────┴───────────────────┴─────────┴───────────────────────────────────┴────────────────────────────────┴────────────────────────────┴──────────────────────────┴──────────────────────────┴───────────────────┴───────────────────┴──────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴──────────────────────────────────────┴──────────────────────────────────────┴───────────────────┴──────────────┴───────────────────┴────────────┴────────────────────┴────────────────┴─────────────┴────────────────────────────┴───────────┴────────────────────────────┴──────────────────────────────────────────────────────────────────────────────┴────────────┴───────────────┴──────────────┴──────────┴─────────────────────┴─────────────────┴─────────────────────────────────────────────────────────────────────────────────────┘
#>   13 rows         
```

## Retrieve expression by representation

### Single-cell counts

``` r
sce_counts <- query_metadata |>
  get_single_cell_experiment()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  2s

                                                                
ℹ Compiling Experiment.
```

``` python
adata_counts = get_anndata(query_metadata)
#> Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene_2024/0.2.1/counts/001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad to /home/juan/.cache/cellNexusPy/cellxgene_2024/0.2.1/single_cell/counts/001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad
#> 1.33MB [00:04, 278kB/s]491 [00:00<?, ?it/s]
#>   0%|          | 0/1390491 [00:04<?, ?it/s]
#> Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene_2024/0.2.1/counts/4a469d94fef0b1c60027fad9eb660b42___1.h5ad to /home/juan/.cache/cellNexusPy/cellxgene_2024/0.2.1/single_cell/counts/4a469d94fef0b1c60027fad9eb660b42___1.h5ad
#> 1.24MB [00:04, 281kB/s]527 [00:00<?, ?it/s]
#>   0%|          | 0/1302527 [00:04<?, ?it/s]
```

### Counts per million

``` r
sce_cpm <- query_metadata |>
  get_single_cell_experiment(assays = "cpm")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  6s

                                                             
ℹ Compiling Experiment.
sce_cpm
#> # A SingleCellExperiment-tibble abstraction: 13 × 59
#> #  [90mFeatures=33145 | Cells=13 | Assays=cpm [0m
#>    .cell observation_joinid dataset_id  sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <chr>              <chr>       <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>
#>  1 16_1  j}0<Y>a#X~         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438
#>  2 19_1  lNmuO5xs~3         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876
#>  3 14_1  qxl7HJjL$L         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547
#>  4 2_1   $jvBt8wHSK         842c6f5d-4… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342
#>  5 21_1  Mq^|(c<-#3         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552
#>  6 24_1  I`4{4__f#J         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800
#>  7 22_1  %vkLP;!cqY         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759
#>  8 11_1  gncTL3)pV~         842c6f5d-4… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399
#>  9 25_2  rfOnkhfWl8         842c6f5d-4… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324
#> 10 24_2  =tj7A<!2TZ         842c6f5d-4… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254
#> 11 13_2  Py{Fqs?~!!         842c6f5d-4… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368
#> 12 9_2   s$u5u14ye$         842c6f5d-4… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767
#> 13 6_2   ?y4kdGGQ!^         842c6f5d-4… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 48 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>,
#> #   sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>,
#> #   .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>, …
```

``` python
adata_cpm = get_anndata(query_metadata, assays=["cpm"])
#> Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene_2024/0.2.1/cpm/4a469d94fef0b1c60027fad9eb660b42___1.h5ad to /home/juan/.cache/cellNexusPy/cellxgene_2024/0.2.1/single_cell/cpm/4a469d94fef0b1c60027fad9eb660b42___1.h5ad
#> 1.24MB [00:04, 306kB/s]387 [00:00<?, ?it/s]
#>   0%|          | 0/1302387 [00:04<?, ?it/s]
#> Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene_2024/0.2.1/cpm/001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad to /home/juan/.cache/cellNexusPy/cellxgene_2024/0.2.1/single_cell/cpm/001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad
#> 1.33MB [00:04, 302kB/s]416 [00:00<?, ?it/s]
#>   0%|          | 0/1390416 [00:04<?, ?it/s]
adata_cpm
#> View of AnnData object with n_obs × n_vars = 13 × 33145
#>     obs: 'cell_id', 'observation_joinid', 'dataset_id', 'sample_id', 'sample_', 'experiment___', 'run_from_cell_id', 'sample_heuristic', 'age_days', 'tissue_groups', 'nFeature_expressed_in_sample', 'nCount_RNA', 'empty_droplet', 'cell_type_unified_ensemble', 'is_immune', 'subsets_Mito_percent', 'subsets_Ribo_percent', 'high_mitochondrion', 'high_ribosome', 'scDblFinder.class', 'sample_chunk', 'cell_chunk', 'sample_pseudobulk_chunk', 'file_id_cellNexus_single_cell', 'file_id_cellNexus_pseudobulk', 'count_upper_bound', 'nfeature_expressed_thresh', 'inverse_transform', 'alive', 'cell_annotation_blueprint_singler', 'cell_annotation_monaco_singler', 'cell_annotation_azimuth_l2', 'ethnicity_flagging_score', 'low_confidence_ethnicity', '.aggregated_cells', 'imputed_ethnicity', 'atlas_id', 'citation', 'collection_id', 'dataset_version_id', 'default_embedding', 'published_at', 'raw_data_location', 'revised_at', 'primary_cell_count', 'schema_version', 'tissue_type', 'title', 'tombstone', 'x_approximate_distribution', 'explorer_url', 'cell_count', 'feature_count', 'filesize', 'filetype', 'mean_genes_per_cell', 'suspension_type', 'url'
#>     layers: 'cpm'
```

### Pseudobulk

``` r

pb_counts <- query_metadata |>
  get_pseudobulk()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
sce_cpm
#> # A SingleCellExperiment-tibble abstraction: 13 × 59
#> # Features=33145 | Cells=13 | Assays=cpm
#>    .cell observation_joinid dataset_id  sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <chr>              <chr>       <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>
#>  1 16_1  j}0<Y>a#X~         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438
#>  2 19_1  lNmuO5xs~3         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876
#>  3 14_1  qxl7HJjL$L         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547
#>  4 2_1   $jvBt8wHSK         842c6f5d-4… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342
#>  5 21_1  Mq^|(c<-#3         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552
#>  6 24_1  I`4{4__f#J         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800
#>  7 22_1  %vkLP;!cqY         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759
#>  8 11_1  gncTL3)pV~         842c6f5d-4… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399
#>  9 25_2  rfOnkhfWl8         842c6f5d-4… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324
#> 10 24_2  =tj7A<!2TZ         842c6f5d-4… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254
#> 11 13_2  Py{Fqs?~!!         842c6f5d-4… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368
#> 12 9_2   s$u5u14ye$         842c6f5d-4… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767
#> 13 6_2   ?y4kdGGQ!^         842c6f5d-4… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 48 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>,
#> #   sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>,
#> #   .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>, …
```

``` python
pb_counts = get_pseudobulk(query_metadata)
#> Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene_2024/0.2.1/pseudobulk/counts/91acbf94110b95b1e994fdb1e1322fd1___1.h5ad to /home/juan/.cache/cellNexusPy/cellxgene_2024/0.2.1/pseudobulk/counts/91acbf94110b95b1e994fdb1e1322fd1___1.h5ad
#> 247MB [02:49, 1.53MB/s]30665 [00:00<?, ?it/s]
#>   0%|          | 0/259330665 [02:49<?, ?it/s]
pb_counts
#> View of AnnData object with n_obs × n_vars = 7 × 33145
#>     obs: 'dataset_id', 'sample_id', 'sample_', 'experiment___', 'run_from_cell_id', 'sample_heuristic', 'age_days', 'tissue_groups', 'cell_type_unified_ensemble', 'sample_chunk', 'cell_chunk', 'sample_pseudobulk_chunk', 'file_id_cellNexus_pseudobulk', 'count_upper_bound', 'nfeature_expressed_thresh', 'inverse_transform', 'ethnicity_flagging_score', 'low_confidence_ethnicity', '.aggregated_cells', 'imputed_ethnicity', 'atlas_id', 'citation', 'collection_id', 'dataset_version_id', 'default_embedding', 'published_at', 'raw_data_location', 'revised_at', 'primary_cell_count', 'schema_version', 'tissue_type', 'title', 'tombstone', 'x_approximate_distribution', 'explorer_url', 'cell_count', 'feature_count', 'filesize', 'filetype', 'mean_genes_per_cell', 'suspension_type', 'url'
#>     layers: 'counts'
```

## Targeted gene queries

``` r
# ENSEMBL IDs are expected
sce_gene <- query_metadata |>
  get_single_cell_experiment(
    assays = "cpm",
    features = "ENSG00000134644"
  )
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  6s

                                                             
ℹ Compiling Experiment.
sce_gene
#> # A SingleCellExperiment-tibble abstraction: 13 × 59
#> #  [90mFeatures=1 | Cells=13 | Assays=cpm [0m
#>    .cell observation_joinid dataset_id  sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <chr>              <chr>       <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>
#>  1 16_1  j}0<Y>a#X~         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438
#>  2 19_1  lNmuO5xs~3         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876
#>  3 14_1  qxl7HJjL$L         842c6f5d-4… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547
#>  4 2_1   $jvBt8wHSK         842c6f5d-4… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342
#>  5 21_1  Mq^|(c<-#3         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552
#>  6 24_1  I`4{4__f#J         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800
#>  7 22_1  %vkLP;!cqY         842c6f5d-4… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759
#>  8 11_1  gncTL3)pV~         842c6f5d-4… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399
#>  9 25_2  rfOnkhfWl8         842c6f5d-4… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324
#> 10 24_2  =tj7A<!2TZ         842c6f5d-4… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254
#> 11 13_2  Py{Fqs?~!!         842c6f5d-4… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368
#> 12 9_2   s$u5u14ye$         842c6f5d-4… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767
#> 13 6_2   ?y4kdGGQ!^         842c6f5d-4… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 48 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>,
#> #   sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>,
#> #   .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>, …
```

``` python
sce_gene = get_anndata(query_metadata,assays=["cpm"], features=["ENSG00000134644"])
sce_gene
#> View of AnnData object with n_obs × n_vars = 13 × 1
#>     obs: 'cell_id', 'observation_joinid', 'dataset_id', 'sample_id', 'sample_', 'experiment___', 'run_from_cell_id', 'sample_heuristic', 'age_days', 'tissue_groups', 'nFeature_expressed_in_sample', 'nCount_RNA', 'empty_droplet', 'cell_type_unified_ensemble', 'is_immune', 'subsets_Mito_percent', 'subsets_Ribo_percent', 'high_mitochondrion', 'high_ribosome', 'scDblFinder.class', 'sample_chunk', 'cell_chunk', 'sample_pseudobulk_chunk', 'file_id_cellNexus_single_cell', 'file_id_cellNexus_pseudobulk', 'count_upper_bound', 'nfeature_expressed_thresh', 'inverse_transform', 'alive', 'cell_annotation_blueprint_singler', 'cell_annotation_monaco_singler', 'cell_annotation_azimuth_l2', 'ethnicity_flagging_score', 'low_confidence_ethnicity', '.aggregated_cells', 'imputed_ethnicity', 'atlas_id', 'citation', 'collection_id', 'dataset_version_id', 'default_embedding', 'published_at', 'raw_data_location', 'revised_at', 'primary_cell_count', 'schema_version', 'tissue_type', 'title', 'tombstone', 'x_approximate_distribution', 'explorer_url', 'cell_count', 'feature_count', 'filesize', 'filetype', 'mean_genes_per_cell', 'suspension_type', 'url'
#>     layers: 'cpm'
```

## Seurat

``` r
# Seurat conversion
seurat_obj <- query_metadata |>
  get_seurat()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  4s

                                                                
ℹ Compiling Experiment.
seurat_obj
#> An object of class Seurat 
#> 33145 features across 13 samples within 1 assay 
#> Active assay: originalexp (33145 features, 0 variable features)
#>  2 layers present: counts, data
```

## Portable output examples

``` r

saveRDS(sce_counts, "single_cell_counts.rds")
HDF5Array::saveHDF5SummarizedExperiment(
  sce_counts,
  "single_cell_counts",
  replace = TRUE,
  as.sparse = TRUE
)
anndataR::write_h5ad(sce_counts, "single_cell_counts.h5ad")
```

``` python
adata_counts.obs.index.name = None
adata_counts.obs["run_from_cell_id"] = adata_counts.obs["run_from_cell_id"].fillna("NA").astype(str)

# convert all remaining object columns to str
for col in adata_counts.obs.select_dtypes(include="object").columns:
    adata_counts.obs[col] = adata_counts.obs[col].fillna("NA").astype(str)

adata_counts.write_h5ad("myH5ADfile.h5ad")
```

``` python
conn.close()
```

## Interpretation notes

- Use `counts` for raw-scale abundance.
- Use `cpm` for normalized cross-cell comparisons.
- Use `rank` for ranked signature.
- Use `sct` for normalized cross-cell comparison by
  [`Seurat::SCTransform`](https://satijalab.org/seurat/reference/SCTransform.html).
- Use `pseudobulk` for sample/cell-type aggregation analyses.

``` r

sessionInfo()
#> R version 4.5.3 (2026-03-11)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Red Hat Enterprise Linux 9.6 (Plow)
#> 
#> Matrix products: default
#> BLAS:   /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRblas.so 
#> LAPACK: /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRlapack.so;  LAPACK version 3.12.1
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8   
#>  [6] LC_MESSAGES=en_US.UTF-8    LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: Australia/Melbourne
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] BiocStyle_2.38.0  ggplot2_4.0.2     dplyr_1.2.1       cellNexus_0.99.22
#> 
#> loaded via a namespace (and not attached):
#>   [1] RcppAnnoy_0.0.23                splines_4.5.3                   later_1.4.8                     filelock_1.0.3                 
#>   [5] tibble_3.3.1                    polyclip_1.10-7                 fastDummies_1.7.5               lifecycle_1.0.5                
#>   [9] rprojroot_2.1.1                 globals_0.19.1                  lattice_0.22-9                  MASS_7.3-65                    
#>  [13] backports_1.5.1                 magrittr_2.0.5                  sass_0.4.10                     plotly_4.12.0                  
#>  [17] rmarkdown_2.31                  jquerylib_0.1.4                 yaml_2.3.12                     httpuv_1.6.17                  
#>  [21] otel_0.2.0                      Seurat_5.5.0.9002               sctransform_0.4.3               spam_2.11-3                    
#>  [25] sp_2.2-1                        sessioninfo_1.2.3               pkgbuild_1.4.8                  spatstat.sparse_3.1-0          
#>  [29] reticulate_1.46.0               cowplot_1.2.0                   pbapply_1.7-4                   DBI_1.3.0                      
#>  [33] RColorBrewer_1.1-3              abind_1.4-8                     pkgload_1.5.1                   Rtsne_0.17                     
#>  [37] GenomicRanges_1.62.1            purrr_1.2.2                     BiocGenerics_0.56.0             tidySingleCellExperiment_1.20.1
#>  [41] IRanges_2.44.0                  S4Vectors_0.49.1-1              ggrepel_0.9.8                   irlba_2.3.7                    
#>  [45] listenv_0.10.1                  spatstat.utils_3.2-2            goftest_1.2-3                   RSpectra_0.16-2                
#>  [49] spatstat.random_3.4-5           fitdistrplus_1.2-6              parallelly_1.46.1               commonmark_2.0.0               
#>  [53] codetools_0.2-20                DelayedArray_0.36.1             xml2_1.5.2                      tidyselect_1.2.1               
#>  [57] rclipboard_0.2.1                UCSC.utils_1.6.1                farver_2.1.2                    shinyWidgets_0.9.1             
#>  [61] matrixStats_1.5.0               stats4_4.5.3                    spatstat.explore_3.8-0          duckdb_1.4.3                   
#>  [65] Seqinfo_1.0.0                   roxygen2_7.3.3                  jsonlite_2.0.0                  ellipsis_0.3.3                 
#>  [69] progressr_0.19.0                ggridges_0.5.7                  survival_3.8-6                  tools_4.5.3                    
#>  [73] ica_1.0-3                       Rcpp_1.1.1-1                    glue_1.8.0                      gridExtra_2.3                  
#>  [77] SparseArray_1.10.10             xfun_0.57                       MatrixGenerics_1.22.0           usethis_3.2.1                  
#>  [81] GenomeInfoDb_1.46.2             HDF5Array_1.38.0                withr_3.0.2                     BiocManager_1.30.27            
#>  [85] fastmap_1.2.0                   basilisk_1.22.0                 fansi_1.0.7                     rhdf5filters_1.22.0            
#>  [89] ttservice_0.5.3                 digest_0.6.39                   R6_2.6.1                        mime_0.13                      
#>  [93] scattermore_1.2                 tensor_1.5.1                    spatstat.data_3.1-9             h5mread_1.2.1                  
#>  [97] utf8_1.2.6                      tidyr_1.3.2                     generics_0.1.4                  data.table_1.18.2.1            
#> [101] httr_1.4.8                      htmlwidgets_1.6.4               S4Arrays_1.10.1                 uwot_0.2.4                     
#> [105] pkgconfig_2.0.3                 gtable_0.3.6                    rsconnect_1.8.0                 blob_1.3.0                     
#> [109] lmtest_0.9-40                   S7_0.2.1-1                      SingleCellExperiment_1.32.0     XVector_0.50.0                 
#> [113] htmltools_0.5.9                 bookdown_0.46                   dotCall64_1.2                   SeuratObject_5.4.0             
#> [117] scales_1.4.0                    Biobase_2.70.0                  png_0.1-9                       spatstat.univar_3.1-7          
#> [121] knitr_1.51                      rstudioapi_0.18.0               reshape2_1.4.5                  checkmate_2.3.4                
#> [125] nlme_3.1-168                    curl_7.0.0                      anndataR_1.0.2                  rhdf5_2.54.1                   
#> [129] cachem_1.1.0                    zoo_1.8-15                      stringr_1.6.0                   KernSmooth_2.23-26             
#> [133] parallel_4.5.3                  miniUI_0.1.2                    arrow_23.0.1.2                  zellkonverter_1.20.1           
#> [137] desc_1.4.3                      pillar_1.11.1                   grid_4.5.3                      vctrs_0.7.3                    
#> [141] RANN_2.6.2                      promises_1.5.0                  dbplyr_2.5.2                    xtable_1.8-8                   
#> [145] cluster_2.1.8.2                 evaluate_1.0.5                  cli_3.6.6                       compiler_4.5.3                 
#> [149] rlang_1.2.0                     future.apply_1.20.2             forcats_1.0.1                   plyr_1.8.9                     
#> [153] fs_2.0.1                        stringi_1.8.7                   viridisLite_0.4.3               deldir_2.0-4                   
#> [157] assertthat_0.2.1                lazyeval_0.2.3                  devtools_2.5.0                  spatstat.geom_3.7-3            
#> [161] Matrix_1.7-4                    dir.expiry_1.18.0               RcppHNSW_0.6.0                  patchwork_1.3.2                
#> [165] bit64_4.6.0-1                   future_1.70.0                   Rhdf5lib_1.32.0                 shiny_1.13.0                   
#> [169] SummarizedExperiment_1.40.0     ROCR_1.0-12                     igraph_2.2.3                    memoise_2.0.1                  
#> [173] bslib_0.10.0                    bit_4.6.0
```

``` python
import session_info
session_info.show()
#> -----
#> cellnexuspy         NA
#> session_info        v1.0.1
#> -----
#> 81d243bd2c585b0f4821__mypyc NA
#> anndata                     0.11.4
#> anyio                       NA
#> appdirs                     1.4.4
#> arrow                       1.4.0
#> asciitree                   NA
#> asttokens                   NA
#> attr                        26.1.0
#> attrs                       26.1.0
#> babel                       2.18.0
#> certifi                     2026.02.25
#> charset_normalizer          3.4.6
#> colorama                    0.4.6
#> comm                        0.2.3
#> cython_runtime              NA
#> dateutil                    2.9.0.post0
#> debugpy                     1.8.20
#> decorator                   5.2.1
#> deprecated                  1.3.1
#> duckdb                      1.5.1
#> executing                   2.2.1
#> fastjsonschema              NA
#> fqdn                        NA
#> h5py                        3.16.0
#> idna                        3.11
#> ipykernel                   7.2.0
#> isoduration                 NA
#> jedi                        0.19.2
#> jinja2                      3.1.6
#> json5                       0.13.0
#> jsonpointer                 3.1.1
#> jsonschema                  4.26.0
#> jsonschema_specifications   NA
#> jupyter_events              0.12.0
#> jupyter_server              2.17.0
#> jupyterlab_server           2.28.0
#> lark                        1.3.1
#> markupsafe                  3.0.3
#> msgpack                     1.1.2
#> natsort                     8.4.0
#> nbformat                    5.10.4
#> numcodecs                   0.15.1
#> numpy                       2.4.3
#> packaging                   26.0
#> pandas                      2.3.3
#> parso                       0.8.6
#> platformdirs                4.9.4
#> prometheus_client           NA
#> prompt_toolkit              3.0.52
#> psutil                      7.2.2
#> pure_eval                   0.2.3
#> pydev_ipython               NA
#> pydevconsole                NA
#> pydevd                      3.2.3
#> pydevd_file_utils           NA
#> pydevd_plugins              NA
#> pydevd_tracing              NA
#> pygments                    2.19.2
#> pythonjsonlogger            NA
#> pytz                        2026.1.post1
#> referencing                 NA
#> requests                    2.33.0
#> rfc3339_validator           0.1.4
#> rfc3986_validator           0.1.1
#> rfc3987_syntax              NA
#> rpds                        NA
#> scipy                       1.17.1
#> send2trash                  NA
#> six                         1.17.0
#> stack_data                  0.6.3
#> torch                       2.11.0+cu130
#> torchgen                    NA
#> tornado                     6.5.5
#> tqdm                        4.67.3
#> traitlets                   5.14.3
#> typing_extensions           NA
#> uri_template                NA
#> urllib3                     2.6.3
#> vscode                      NA
#> wcwidth                     0.6.0
#> webcolors                   NA
#> websocket                   1.9.0
#> wrapt                       2.1.2
#> yaml                        6.0.3
#> zarr                        2.18.7
#> zmq                         27.1.0
#> -----
#> IPython             9.11.0
#> jupyter_client      8.8.0
#> jupyter_core        5.9.1
#> jupyterlab          4.5.6
#> notebook            7.5.5
#> -----
#> Python 3.14.3 | packaged by conda-forge | (main, Feb  9 2026, 21:56:02) [GCC 14.3.0]
#> Linux-6.17.0-29-generic-x86_64-with-glibc2.39
#> -----
#> Session information updated at 2026-06-09 18:26
```
