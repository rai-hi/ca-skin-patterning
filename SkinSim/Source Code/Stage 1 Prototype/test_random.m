function test_random()
%TEST_RANDOM Used to test the performance of random_distribution

sum_values=zeros(1,100);
for i=1:1000
    
    init=random_distribution(20,20,10);
    sum_values(i)=sum(sum(init));

end
avg=mean(sum_values);
std_dev=std(sum_values);

disp('Predicted average: 40 (10% of 400 cell grid (20x20))')
disp(strcat('Actual average: ',num2str(avg)))
disp(strcat('Standard deviation: ',num2str(std_dev)))