@str0 = private unnamed_addr constant [37 x i8] c"Prime numbers between 1 and 1000:\n\0A\00", align 1
@str1 = private unnamed_addr constant [6 x i8] c"%d\n\0A\00", align 1
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
%t3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([37 x i8], [37 x i8]* @str0, i64 0, i64 0))
store i32 2, i32* %t0, align 4
br label %L0cond
L0cond:
%t4 = load i32, i32* %t0
%cond0 = icmp sle i32 %t4, 300
br i1 %cond0, label %L0body, label %L0end
L0inc:
%t5 = load i32, i32* %t0
%t6 = add nsw i32 %t5, 1
store i32 %t6, i32* %t0, align 4
br label %L0cond
L0body:
store i32 1, i32* %t2, align 4
store i32 2, i32* %t1, align 4
br label %L1cond
L1cond:
%t7 = load i32, i32* %t1
%t8 = load i32, i32* %t0
%cond1 = icmp slt i32 %t7, %t8
br i1 %cond1, label %L1true, label %L1false
L1true:
%t9 = load i32, i32* %t0
%t10 = load i32, i32* %t1
%t11 = srem i32 %t9, %t10
%cond2 = icmp eq i32 %t11, 0
br i1 %cond2, label %L2true, label %L2false
L2true:
store i32 0, i32* %t2, align 4
br label %L2end
L2false:
br label %L2end
L2end:
%t12 = load i32, i32* %t1
%t13 = add nsw i32 %t12, 1
store i32 %t13, i32* %t1, align 4
br label %L1cond
L1false:
%t14 = load i32, i32* %t2
%cond3 = icmp ne i32 %t14, 0
br i1 %cond3, label %L3true, label %L3false
L3true:
%t16 = load i32, i32* %t0
%t15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str1, i64 0, i64 0), i32 %t16)
br label %L3end
L3false:
br label %L3end
L3end:
br label %L0inc
L0end:
ret i32 0
}
