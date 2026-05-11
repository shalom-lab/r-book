library(yaml)
library(purrr)

# 定义函数：读取章节 YAML 文件中的 `part,chapters`
read_chapters <- function(path) {
  if (file.exists(path)) {
    # 读取 YAML 文件
    config <- yaml.load_file(path)
    # 返回 chapters 部分
    return(c(part=config$part,
             chapters=list(map(config$chapters,~{
               list(text=.x$text,href=gsub('_quarto.yml',.x$href,path))
             }))
             ))
  }
  return(NULL)
}

#read_chapters('chapter/clean/_quarto.yml')

# 读取全局配置
global_config<-read_yaml('_quarto.yml')

chapter_dirs<-c('base','clean','viz','stats')
chapter_ymls<-paste0('chapter/',chapter_dirs,'/_quarto.yml')
global_chapters<-lapply(chapter_ymls,function(x){read_chapters(x)})
global_chapters<-c('index.qmd',global_chapters)

global_config$book$chapters<-global_chapters
global_config$book$date <- format(Sys.time(), "%Y/%m/%d")

write_yaml(global_config, "_quarto.yml")

# 3. 暴力后处理
lines <- readLines("_quarto.yml", encoding = "UTF-8")

# 修正后的正则：
# 匹配 date: 开头，后面跟着非引号的内容，把它包起来
lines <- gsub("^date: ([^\".]*)", "date: \"\\1\"", lines)

# 匹配 text: Copyright 开头的内容，把它包起来
lines <- gsub("text: (Copyright[^\"]*)", "text: \"\\1\"", lines)

# 4. 写回
writeLines(lines, "_quarto.yml", useBytes = TRUE)

