cd ..
echo "> # Main App # lib:"
find ./lib -name "*.dart" -type f|xargs wc -l | grep total
