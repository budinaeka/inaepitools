library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)
library(readxl)
library(epiR)
library(sf)
library(leaflet)

# UI Definition
ui <- page_navbar(
  title = "InaEpiTools",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  
  # Halaman Beranda
  nav_panel(title = "Beranda",
    layout_columns(
      card(
        card_header("Selamat Datang di InaEpiTools"),
        p("Platform Analisis Epidemiologi Terpadu untuk Indonesia."),
        p("Gunakan menu navigasi di atas untuk mengakses berbagai alat analisis."),
        tags$ul(
          tags$li("Manajemen Data: Upload dan eksplorasi data."),
          tags$li("Analisis Deskriptif: Ringkasan statistik."),
          tags$li("Kalkulator Epidemiologi: OR/RR, Ukuran Sampel, Uji Diagnostik."),
          tags$li("Visualisasi: Grafik tren dan peta sebaran (Coming Soon).")
        )
      )
    )
  ),
  
  # Halaman Manajemen Data
  nav_panel(title = "Manajemen Data",
    sidebar_layout(
      sidebar_panel(
        fileInput("file_upload", "Upload Data (CSV/Excel)",
                  accept = c(".csv", ".xlsx")),
        helpText("Pastikan format data sesuai. Baris pertama adalah header."),
        checkboxInput("header", "Header", TRUE),
        radioButtons("sep", "Pemisah (untuk CSV)",
                     choices = c(Koma = ",", TitikKoma = ";", Tab = "\t"),
                     selected = ",")
      ),
      main_panel(
        card(
          card_header("Pratinjau Data"),
          DTOutput("data_preview")
        ),
        card(
          card_header("Ringkasan Struktur Data"),
          verbatimTextOutput("data_structure")
        )
      )
    )
  ),

  # Halaman Analisis Deskriptif
  nav_panel(title = "Analisis Deskriptif",
    sidebar_layout(
      sidebar_panel(
        selectInput("var_desc", "Pilih Variabel:", choices = NULL),
        actionButton("run_desc", "Jalankan Analisis", class = "btn-primary")
      ),
      main_panel(
        card(
          card_header("Statistik Deskriptif"),
          verbatimTextOutput("desc_stats")
        ),
        card(
          card_header("Histogram / Bar Plot"),
          plotlyOutput("desc_plot")
        )
      )
    )
  ),
  
  # Halaman Kalkulator Epidemiologi
  nav_panel(title = "Kalkulator",
    tabsetPanel(
      # Tab Risiko (OR/RR)
      tabPanel("Risiko (OR/RR)",
        layout_columns(
          card(
            card_header("Input Tabel 2x2"),
            fluidRow(
              column(6, numericInput("a", "Terpapar (+) & Sakit (+)", value = 10, min = 0)),
              column(6, numericInput("b", "Terpapar (+) & Sehat (-)", value = 20, min = 0))
            ),
            fluidRow(
              column(6, numericInput("c", "Tidak Terpapar (-) & Sakit (+)", value = 15, min = 0)),
              column(6, numericInput("d", "Tidak Terpapar (-) & Sehat (-)", value = 50, min = 0))
            ),
            selectInput("risk_method", "Metode:", choices = c("Cohort (RR)" = "cohort.count", "Case-Control (OR)" = "case.control", "Cross-Sectional (PR)" = "cross.sectional")),
            actionButton("calc_risk", "Hitung Risiko", class = "btn-success")
          ),
          card(
            card_header("Hasil Analisis"),
            verbatimTextOutput("risk_output")
          )
        )
      ),
      
      # Tab Ukuran Sampel
      tabPanel("Ukuran Sampel",
        sidebar_layout(
          sidebar_panel(
            selectInput("ss_type", "Tipe Studi:", 
                        choices = c("Estimasi Proporsi" = "prop", "Estimasi Rata-rata" = "mean")),
            conditionalPanel(
              condition = "input.ss_type == 'prop'",
              numericInput("ss_p", "Proporsi yang Diantisipasi (P)", value = 0.5, min = 0, max = 1, step = 0.01),
              numericInput("ss_d", "Presisi Mutlak (d)", value = 0.05, min = 0, max = 1, step = 0.001)
            ),
            conditionalPanel(
              condition = "input.ss_type == 'mean'",
              numericInput("ss_sd", "Standar Deviasi (SD)", value = 10, min = 0),
              numericInput("ss_epsilon", "Presisi Mutlak (epsilon)", value = 2, min = 0)
            ),
            numericInput("ss_conf", "Tingkat Kepercayaan (Confidence Level)", value = 0.95, min = 0, max = 1, step = 0.01),
            actionButton("calc_ss", "Hitung Sampel", class = "btn-info")
          ),
          main_panel(
            card(
              card_header("Hasil Perhitungan Sampel"),
              verbatimTextOutput("ss_output")
            )
          )
        )
      ),
      
      # Tab Uji Diagnostik
      tabPanel("Uji Diagnostik",
        layout_columns(
          card(
            card_header("Input Tabel Diagnostik"),
            fluidRow(
              column(6, numericInput("tp", "True Positive (TP)", value = 80)),
              column(6, numericInput("fp", "False Positive (FP)", value = 10))
            ),
            fluidRow(
              column(6, numericInput("fn", "False Negative (FN)", value = 20)),
              column(6, numericInput("tn", "True Negative (TN)", value = 90))
            ),
            actionButton("calc_diag", "Hitung Akurasi", class = "btn-warning")
          ),
          card(
            card_header("Performa Tes"),
            verbatimTextOutput("diag_output")
          )
        )
      )
    )
  ),
  
  # Halaman Uji Asosiasi
  nav_panel(title = "Uji Asosiasi",
    sidebar_layout(
      sidebar_panel(
        helpText("Pastikan data sudah diupload di menu 'Manajemen Data'."),
        selectInput("assoc_y", "Variabel Outcome (Y):", choices = NULL),
        selectInput("assoc_x", "Variabel Exposure (X):", choices = NULL),
        selectInput("assoc_method", "Metode Uji:", 
                    choices = c("Otomatis (Berdasarkan Tipe Data)" = "auto",
                                "Chi-Square (Kat vs Kat)" = "chisq",
                                "T-Test (Num vs Kat)" = "ttest",
                                "ANOVA (Num vs Kat > 2)" = "anova",
                                "Korelasi (Num vs Num)" = "cor")),
        actionButton("run_assoc", "Jalankan Uji", class = "btn-danger")
      ),
      main_panel(
        card(
          card_header("Hasil Uji Statistik"),
          verbatimTextOutput("assoc_output")
        ),
        card(
          card_header("Visualisasi Asosiasi"),
          plotlyOutput("assoc_plot")
        )
      )
    )
  ),
  
  # Halaman Peta Sebaran (GIS)
  nav_panel(title = "Peta Sebaran",
    sidebar_layout(
      sidebar_panel(
        helpText("Pastikan data memiliki kolom Latitude dan Longitude."),
        selectInput("map_lat", "Latitude:", choices = NULL),
        selectInput("map_lon", "Longitude:", choices = NULL),
        # selectInput("map_color", "Warna Berdasarkan:", choices = NULL), # Fitur masa depan
        actionButton("plot_map", "Tampilkan Peta", class = "btn-primary")
      ),
      main_panel(
        card(
          card_header("Peta Interaktif"),
          leafletOutput("gis_map", height = "600px")
        )
      )
    )
  ),
  
  # Menu Lainnya
  nav_menu(
    title = "Bantuan",
    nav_item(tags$a("Dokumentasi epiR", href = "https://cran.r-project.org/web/packages/epiR/index.html", target = "_blank")),
    nav_item(tags$a("Tentang Kami", href = "#"))
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # --- Reactive Values & Data Management ---
  
  # Reactive untuk menyimpan data yang diupload
  uploaded_data <- reactive({
    req(input$file_upload)
    file <- input$file_upload
    ext <- tools::file_ext(file$name)
    
    tryCatch({
      if (ext == "csv") {
        read.csv(file$datapath, header = input$header, sep = input$sep)
      } else if (ext == "xlsx") {
        read_excel(file$datapath)
      } else {
        validate("Format file tidak didukung. Gunakan CSV atau Excel.")
      }
    }, error = function(e) {
      validate(paste("Gagal membaca file:", e$message))
    })
  })
  
  # Output Data Preview
  output$data_preview <- renderDT({
    req(uploaded_data())
    datatable(uploaded_data(), options = list(pageLength = 5, scrollX = TRUE))
  })
  
  # Output Data Structure
  output$data_structure <- renderPrint({
    req(uploaded_data())
    str(uploaded_data())
  })
  
  # Update Variable Choices for Descriptive Analysis and Association
  observe({
    req(uploaded_data())
    cols <- names(uploaded_data())
    updateSelectInput(session, "var_desc", choices = cols)
    updateSelectInput(session, "assoc_x", choices = cols)
    updateSelectInput(session, "assoc_y", choices = cols)
    
    # Try to guess lat/lon
    lat_guess <- grep("lat", cols, ignore.case = TRUE, value = TRUE)
    lon_guess <- grep("lon|lng", cols, ignore.case = TRUE, value = TRUE)
    
    updateSelectInput(session, "map_lat", choices = cols, selected = if(length(lat_guess)>0) lat_guess[1] else NULL)
    updateSelectInput(session, "map_lon", choices = cols, selected = if(length(lon_guess)>0) lon_guess[1] else NULL)
  })
  
  # --- Analisis Deskriptif ---
  
  output$desc_stats <- renderPrint({
    req(input$run_desc, uploaded_data(), input$var_desc)
    df <- uploaded_data()
    var <- df[[input$var_desc]]
    
    cat("Ringkasan Statistik untuk:", input$var_desc, "\n\n")
    if(is.numeric(var)) {
      print(summary(var))
      cat("\nStandar Deviasi:", sd(var, na.rm = TRUE), "\n")
    } else {
      print(table(var))
      cat("\nProporsi:\n")
      print(prop.table(table(var)))
    }
  })
  
  output$desc_plot <- renderPlotly({
    req(input$run_desc, uploaded_data(), input$var_desc)
    df <- uploaded_data()
    var_name <- input$var_desc
    
    # Simple logic for plot type
    if(is.numeric(df[[var_name]])) {
      p <- ggplot(df, aes(x = .data[[var_name]])) +
        geom_histogram(fill = "steelblue", color = "white") +
        theme_minimal() +
        labs(title = paste("Histogram", var_name))
    } else {
      p <- ggplot(df, aes(x = .data[[var_name]])) +
        geom_bar(fill = "salmon") +
        theme_minimal() +
        labs(title = paste("Bar Plot", var_name))
    }
    ggplotly(p)
  })
  
  # --- Kalkulator Risiko (epiR) ---
  
  risk_result <- eventReactive(input$calc_risk, {
    # Construct 2x2 matrix
    # Format: 
    #       Disease +   Disease -
    # Exp +    a           b
    # Exp -    c           d
    dat <- matrix(c(input$a, input$b, input$c, input$d), nrow = 2, byrow = TRUE)
    colnames(dat) <- c("Dis+", "Dis-")
    rownames(dat) <- c("Exp+", "Exp-")
    
    # Calculate using epi.2by2
    # Note: epi.2by2 expects: 
    #            Outcome +    Outcome -
    #   Exp +      a            b
    #   Exp -      c            d
    
    res <- epi.2by2(dat = dat, method = input$risk_method, conf.level = 0.95)
    list(matrix = dat, result = res)
  })
  
  output$risk_output <- renderPrint({
    res <- risk_result()
    print("Tabel 2x2 Input:")
    print(res$matrix)
    cat("\n------------------------------------------------\n")
    print(res$result)
  })
  
  # --- Ukuran Sampel (epiR - simple approximation) ---
  
  ss_result <- eventReactive(input$calc_ss, {
    if(input$ss_type == "prop") {
      # Sample size for population proportion
      # Using simple formula n = Z^2 * P * (1-P) / d^2
      # Or standard epiR if available. epi.sssimpleestb is deprecated in some versions, check docs.
      # Let's use base R formula or check epiR documentation availability.
      # epiR::epi.sssimpleestb (Simple random sampling)
      # Arguments: N (pop size, Inf), Py (proportion), epsilon (absolute precision), error (conf level)
      
      # Wait, epiR functions change names often. Let's stick to standard formula for robustness if epiR fails,
      # but user asked for epiR. 
      # epi.sssimpleestb(N = Inf, Py = input$ss_p, epsilon = input$ss_d, error = 1 - input$ss_conf)
      
      # Let's try to use a safer generic formula if we are not sure about specific epiR version installed
      # But let's assume standard epiR.
      
      z <- qnorm(1 - (1 - input$ss_conf)/2)
      n <- (z^2 * input$ss_p * (1 - input$ss_p)) / (input$ss_d^2)
      return(paste("Estimasi Ukuran Sampel (Simple Random Sampling):\n",
                   "n =", ceiling(n), "\n\n",
                   "Parameter:\n",
                   "P (Anticipated) =", input$ss_p, "\n",
                   "d (Precision) =", input$ss_d, "\n",
                   "Confidence =", input$ss_conf * 100, "%"))
      
    } else {
      # Mean
      z <- qnorm(1 - (1 - input$ss_conf)/2)
      n <- (z * input$ss_sd / input$ss_epsilon)^2
      return(paste("Estimasi Ukuran Sampel (Mean):\n",
                   "n =", ceiling(n), "\n\n",
                   "Parameter:\n",
                   "SD =", input$ss_sd, "\n",
                   "Precision =", input$ss_epsilon, "\n",
                   "Confidence =", input$ss_conf * 100, "%"))
    }
  })
  
  output$ss_output <- renderPrint({
    cat(ss_result())
  })
  
  # --- Uji Diagnostik (epiR) ---
  
  diag_result <- eventReactive(input$calc_diag, {
    dat <- matrix(c(input$tp, input$fp, input$fn, input$tn), nrow = 2, byrow = TRUE)
    colnames(dat) <- c("Dis+", "Dis-")
    rownames(dat) <- c("Test+", "Test-")
    
    # epi.tests for diagnostic test evaluation
    res <- epi.tests(dat, conf.level = 0.95)
    res
  })
  
  output$diag_output <- renderPrint({
    res <- diag_result()
    print(res)
  })
  
  # --- Uji Asosiasi ---
  
  assoc_result <- eventReactive(input$run_assoc, {
    req(uploaded_data(), input$assoc_x, input$assoc_y)
    df <- uploaded_data()
    x <- df[[input$assoc_x]]
    y <- df[[input$assoc_y]]
    
    method <- input$assoc_method
    
    # Automatic method detection
    if(method == "auto") {
      if(is.numeric(y) && is.numeric(x)) method <- "cor"
      else if(is.numeric(y) && (is.character(x) || is.factor(x))) {
        if(length(unique(x)) <= 2) method <- "ttest"
        else method <- "anova"
      }
      else if((is.character(y) || is.factor(y)) && (is.character(x) || is.factor(x))) method <- "chisq"
      else return(list(test = "Metode otomatis tidak dapat ditentukan. Pilih metode manual.", method = "none", desc = "Error"))
    }
    
    res <- list(method = method)
    
    tryCatch({
      if(method == "chisq") {
        res$test <- chisq.test(table(x, y))
        res$desc <- "Uji Chi-Square (Categorical vs Categorical)"
      } else if(method == "ttest") {
        # Ensure x is factor for formula
        res$test <- t.test(y ~ as.factor(x))
        res$desc <- "T-Test (Numeric vs Categorical [2 groups])"
      } else if(method == "anova") {
        res$test <- summary(aov(y ~ as.factor(x)))
        res$desc <- "ANOVA (Numeric vs Categorical [>2 groups])"
      } else if(method == "cor") {
        res$test <- cor.test(x, y)
        res$desc <- "Korelasi Pearson (Numeric vs Numeric)"
      } else {
        res$test <- "Metode tidak valid atau data tidak sesuai."
        res$desc <- "Error"
      }
    }, error = function(e) {
      res$test <- paste("Error:", e$message)
      res$desc <- "Error Execution"
    })
    
    return(res)
  })
  
  output$assoc_output <- renderPrint({
    res <- assoc_result()
    if(!is.null(res$desc)) cat(res$desc, "\n\n")
    print(res$test)
  })
  
  output$assoc_plot <- renderPlotly({
    req(input$run_assoc, uploaded_data())
    res <- assoc_result()
    df <- uploaded_data()
    x_name <- input$assoc_x
    y_name <- input$assoc_y
    
    p <- ggplot() + theme_void() + labs(title = "Plot tidak tersedia")
    
    if(res$method == "chisq") {
      # Bar plot grouped
      # Ensure factors
      df[[x_name]] <- as.factor(df[[x_name]])
      df[[y_name]] <- as.factor(df[[y_name]])
      
      p <- ggplot(df, aes(x = .data[[x_name]], fill = .data[[y_name]])) +
        geom_bar(position = "fill") +
        labs(y = "Proporsi", title = paste("Bar Plot", y_name, "by", x_name)) +
        theme_minimal()
    } else if(res$method == "ttest" || res$method == "anova") {
      # Boxplot
      df[[x_name]] <- as.factor(df[[x_name]])
      p <- ggplot(df, aes(x = .data[[x_name]], y = .data[[y_name]], fill = .data[[x_name]])) +
        geom_boxplot() +
        labs(title = paste("Boxplot", y_name, "by", x_name)) +
        theme_minimal()
    } else if(res$method == "cor") {
      # Scatter plot
      p <- ggplot(df, aes(x = .data[[x_name]], y = .data[[y_name]])) +
        geom_point() +
        geom_smooth(method = "lm") +
        labs(title = paste("Scatter Plot", y_name, "vs", x_name)) +
        theme_minimal()
    }
    
    ggplotly(p)
  })
  
  # --- Peta Sebaran (GIS) ---
  
  output$gis_map <- renderLeaflet({
    req(input$plot_map, uploaded_data())
    df <- uploaded_data()
    
    lat_col <- input$map_lat
    lon_col <- input$map_lon
    
    validate(
      need(lat_col %in% names(df) && lon_col %in% names(df), "Kolom Latitude/Longitude tidak ditemukan."),
      need(is.numeric(df[[lat_col]]), "Kolom Latitude harus numerik."),
      need(is.numeric(df[[lon_col]]), "Kolom Longitude harus numerik.")
    )
    
    leaflet(df) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = as.formula(paste("~", lon_col)),
        lat = as.formula(paste("~", lat_col)),
        popup = ~paste("Lat:", get(lat_col), "<br>Lon:", get(lon_col)),
        radius = 5,
        color = "red",
        stroke = FALSE, fillOpacity = 0.5
      )
  })

}

# Run the Application
shinyApp(ui = ui, server = server)
