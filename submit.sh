# 提交到github
echo "---------------------------首先更新----------------------------------"
git pull
echo "--------------------------------------------------------------------"
echo "-------------------------- 从源代码生成html---------------------------"
rake generate
echo "--------------------------------------------------------------------"
echo "----------------------------- git add ------------------------------"
git add .
echo "--------------------------------------------------------------------"
echo "----------------------- 填写提交注释：自动提交 ------------------------"
git commit -am "自动提交" 
echo "--------------------------------------------------------------------"
echo "----------------------- git 提交到source分支 ------------------------"
git push origin source
echo "--------------------------------------------------------------------"
echo "------------------------ git 部署到github----------------------------"
rake deploy