#!/bin/bash
# ============================================================
# RoboRave Korea Open Dashboard - GitHub Pages 자동 배포 스크립트
# ============================================================
# 사용법:
#   chmod +x deploy.sh
#   ./deploy.sh
# ============================================================

set -e

REPO_NAME="roborave-korea-dashboard"
REPO_DESC="RoboRave Korea Open Competition Dashboard"

echo ""
echo "🤖 RoboRave Korea Open - GitHub Pages 배포 스크립트"
echo "======================================================"
echo ""

# ── Step 1: gh CLI 확인 ──────────────────────────────────
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI(gh)가 설치되어 있지 않습니다."
  echo ""
  echo "설치 방법:"
  echo "  macOS:   brew install gh"
  echo "  Windows: winget install --id GitHub.cli"
  echo "  Linux:   https://cli.github.com 참조"
  echo ""
  exit 1
fi

echo "✅ GitHub CLI 확인됨: $(gh --version | head -1)"
echo ""

# ── Step 2: 로그인 확인 ──────────────────────────────────
if ! gh auth status &> /dev/null; then
  echo "🔐 GitHub 로그인이 필요합니다."
  echo ""
  gh auth login
fi

GITHUB_USER=$(gh api user --jq '.login')
echo "✅ GitHub 사용자: $GITHUB_USER"
echo ""

# ── Step 3: 저장소 생성 ──────────────────────────────────
echo "📁 GitHub 저장소 생성 중: $REPO_NAME"

if gh repo view "$GITHUB_USER/$REPO_NAME" &> /dev/null; then
  echo "   ⚠️  저장소가 이미 존재합니다. 기존 저장소를 사용합니다."
else
  gh repo create "$REPO_NAME" \
    --public \
    --description "$REPO_DESC" \
    --source=. \
    --remote=origin
  echo "   ✅ 저장소 생성 완료"
fi

echo ""

# ── Step 4: remote 설정 ──────────────────────────────────
if git remote get-url origin &> /dev/null; then
  git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
  git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
fi

# ── Step 5: Push ─────────────────────────────────────────
echo "⬆️  코드 업로드 중..."
git push -u origin main --force
echo "   ✅ 업로드 완료"
echo ""

# ── Step 6: GitHub Pages 활성화 ──────────────────────────
echo "🌐 GitHub Pages 활성화 중..."
sleep 2
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GITHUB_USER/$REPO_NAME/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" \
  2>/dev/null || \
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GITHUB_USER/$REPO_NAME/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" \
  2>/dev/null || true

echo "   ✅ GitHub Pages 설정 완료"
echo ""

# ── 완료 ─────────────────────────────────────────────────
PAGES_URL="https://$GITHUB_USER.github.io/$REPO_NAME"
REPO_URL="https://github.com/$GITHUB_USER/$REPO_NAME"

echo "======================================================"
echo "🎉 배포 완료!"
echo ""
echo "📌 저장소:    $REPO_URL"
echo "🌐 웹사이트:  $PAGES_URL"
echo ""
echo "⏳ GitHub Pages 첫 배포는 1~3분 정도 소요됩니다."
echo "   위 URL로 접속해보세요!"
echo "======================================================"
