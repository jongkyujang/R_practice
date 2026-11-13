# ============================================================
# RNA 발현 데이터 분석: 계층적 군집화 및 Heatmap
# 실행 방법: 커서를 줄에 놓고 Shift + Enter 로 한 줄씩 실행
#
# 주의: 여기서 사용하는 데이터(data/expression.csv)는
# 교육용 가상 데이터입니다. 실제 연구 결과가 아닙니다.
# ============================================================


# ── 1. 데이터 불러오기 ──────────────────────────────────────

# read.csv(): CSV 파일을 데이터 프레임으로 불러옵니다
# 상대 경로 사용: 작업 디렉터리 기준
raw <- read.csv("data/expression.csv")

# 불러온 데이터 확인
dim(raw)      # 행 수, 열 수 확인 (40 유전자 × 13 열)
head(raw)     # 처음 6행 확인
str(raw)      # 각 열의 데이터 타입 확인


# ── 2. 유전자명을 행 이름으로 지정 ──────────────────────────

# 현재 첫 번째 열(Gene)에 유전자 이름이 있습니다.
# 이를 행 이름(rownames)으로 옮겨야 행렬 변환이 깔끔합니다.
rownames(raw) <- raw$Gene    # 첫 번째 열을 행 이름으로
raw <- raw[, -1]             # 첫 번째 열(Gene) 제거

head(raw)         # 행 이름이 생겼는지 확인
rownames(raw)     # 유전자 이름 목록


# ── 3. 숫자 행렬로 변환 ──────────────────────────────────────

# heatmap()은 데이터 프레임이 아닌 행렬(matrix)을 요구합니다.
mat <- as.matrix(raw)

class(mat)    # "matrix" "array" 가 나와야 합니다
dim(mat)      # 40 × 12


# ── 4. 행별 스케일링(Row Scaling)이란? ──────────────────────

# 발현값의 절대적 크기는 유전자마다 다릅니다.
# → 어떤 유전자는 보통 발현값이 8, 어떤 유전자는 보통 1
# 그대로 색칠하면 절대값 크기에만 색이 치우칩니다.
#
# scale = "row" 옵션:
#   각 행(유전자)을 평균 0, 표준편차 1로 표준화합니다.
#     z = (값 - 행 평균) / 행 표준편차
#   → 모든 유전자를 같은 기준으로 비교할 수 있습니다.
#   → 색은 "이 유전자가 평균보다 높은가 낮은가"를 나타냅니다.

# 한 유전자(MYC)의 행 스케일링을 직접 계산해보기
myc <- mat["MYC", ]
myc                               # 원래 값
(myc - mean(myc)) / sd(myc)      # 직접 표준화
scale(t(mat))["MYC", ]           # scale()로 확인 (같은 결과)


# ── 5. 샘플 간 계층적 군집화와 덴드로그램 ──────────────────

# 군집화 순서:
#   (1) 샘플 간 거리 계산 → dist()
#   (2) 거리를 기반으로 군집 형성 → hclust()
#   (3) 덴드로그램으로 시각화 → plot()

# 샘플 기준으로 거리를 계산하려면 행렬을 전치(t)해야 합니다
#   mat: 40(유전자) × 12(샘플) → t(mat): 12(샘플) × 40(유전자)
sample_dist <- dist(t(mat), method = "euclidean")
sample_dist   # 거리 행렬 출력

# 계층적 군집화 (complete linkage)
sample_hclust <- hclust(sample_dist, method = "complete")

# 덴드로그램 그리기
plot(sample_hclust,
     main = "샘플 간 계층적 군집화",
     xlab = "샘플",
     ylab = "거리",
     sub  = "")

# → Tumor와 Normal 샘플이 각각 묶이는지 확인해보세요.


# ── 6. 유전자 간 계층적 군집화 ──────────────────────────────

# 유전자 기준으로도 같은 과정을 적용합니다 (전치 없이)
gene_dist   <- dist(mat, method = "euclidean")
gene_hclust <- hclust(gene_dist, method = "complete")

# 덴드로그램 (유전자 이름이 많아 가로로 그립니다)
plot(gene_hclust,
     hang = -1,
     main = "유전자 간 계층적 군집화",
     xlab = "",
     ylab = "거리",
     cex  = 0.7)   # 글씨 크기 70%


# ── 7. Heatmap 작성 ──────────────────────────────────────────

# heatmap() 은 base R 기본 함수입니다.
# scale = "row" 를 지정하면 내부적으로 행별 표준화를 수행합니다.
# 행(유전자)과 열(샘플) 모두 계층적 군집화 결과로 재정렬됩니다.

# 색상 팔레트 정의: 파랑(낮음) → 흰색(중간) → 빨강(높음)
색상 <- colorRampPalette(c("blue", "white", "red"))(100)

# heatmap 그리기
heatmap(mat,
        scale  = "row",    # 행별 z-score 정규화
        col    = 색상,
        main   = "RNA 발현 Heatmap (가상 데이터)",
        xlab   = "샘플",
        ylab   = "유전자",
        cexRow = 0.7,      # 행 이름 크기
        cexCol = 0.9)      # 열 이름 크기


# ── 8. 추가 탐색 (선택) ──────────────────────────────────────

# 군집화 없이 원래 순서 그대로 그리기 (Rowv, Colv = NA)
heatmap(mat,
        Rowv  = NA,
        Colv  = NA,
        scale = "row",
        col   = 색상,
        main  = "군집화 없는 Heatmap (원래 순서)",
        cexRow = 0.7,
        cexCol = 0.9)

# 두 heatmap을 비교하면 군집화가 패턴을 얼마나 명확히 드러내는지 볼 수 있습니다.

# 데이터에 대한 간단한 요약 통계
summary(mat)    # 각 샘플의 최솟값, 중앙값, 최댓값 등
