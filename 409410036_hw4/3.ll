@str0 = private unnamed_addr constant [23 x i8] c"a is greater than b\n\0A\00", align 1
@str1 = private unnamed_addr constant [28 x i8] c"a is also greater than c\n\0A\00", align 1
@str2 = private unnamed_addr constant [17 x i8] c"Iteration: %d\n\0A\00", align 1
@str3 = private unnamed_addr constant [24 x i8] c"Nested Iteration: %d\n\0A\00", align 1
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
%t3 = alloca i32, align 4
%t4 = alloca i32, align 4
store i32 70, i32* %t0, align 4
store i32 30, i32* %t1, align 4
store i32 40, i32* %t2, align 4
store i32 50, i32* %t3, align 4
store i32 60, i32* %t4, align 4
%t5 = load i32, i32* %t0
%t6 = load i32, i32* %t1
%cond0 = icmp sgt i32 %t5, %t6
br i1 %cond0, label %L0true, label %L0false
L0true:
%t7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @str0, i64 0, i64 0))
%t8 = load i32, i32* %t0
%t9 = load i32, i32* %t2
%cond1 = icmp sgt i32 %t8, %t9
br i1 %cond1, label %L1true, label %L1false
L1true:
%t10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @str1, i64 0, i64 0))
br label %L1end
L1false:
br label %L1end
L1end:
store i32 0, i32* %t3, align 4
br label %L2cond
L2cond:
%t11 = load i32, i32* %t3
%cond2 = icmp slt i32 %t11, 5
br i1 %cond2, label %L2body, label %L2end
L2inc:
%t12 = load i32, i32* %t3
%t13 = add nsw i32 %t12, 1
store i32 %t13, i32* %t3, align 4
br label %L2cond
L2body:
%t15 = load i32, i32* %t3
%t14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @str2, i64 0, i64 0), i32 %t15)
store i32 0, i32* %t4, align 4
br label %L3cond
L3cond:
%t16 = load i32, i32* %t4
%cond3 = icmp slt i32 %t16, 3
br i1 %cond3, label %L3body, label %L3end
L3inc:
%t17 = load i32, i32* %t4
%t18 = add nsw i32 %t17, 1
store i32 %t18, i32* %t4, align 4
br label %L3cond
L3body:
%t20 = load i32, i32* %t4
%t19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @str3, i64 0, i64 0), i32 %t20)
br label %L3inc
L3end:
br label %L2inc
L2end:
br label %L0end
L0false:
br label %L0end
L0end:
ret i32 0
}
