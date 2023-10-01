@str0 = private unnamed_addr constant [6 x i8] c"%d\n\0A\00", align 1
@str1 = private unnamed_addr constant [9 x i8] c"%d %d\n\0A\00", align 1
@str2 = private unnamed_addr constant [6 x i8] c"%d\n\0A\00", align 1
@str3 = private unnamed_addr constant [12 x i8] c"1.c>1.ll\n\0A\00", align 1
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
store i32 1, i32* %t1, align 4
%t3 = load i32, i32* %t1
%t4 = sub nsw i32 100, 2
%t5 = mul nsw i32 2, %t4
%t6 = add nsw i32 %t3, %t5
store i32 %t6, i32* %t0, align 4
store i32 3, i32* %t2, align 4
%t8 = load i32, i32* %t1
%t7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str0, i64 0, i64 0), i32 %t8)
%t9 = load i32, i32* %t0
%t10 = load i32, i32* %t1
%t11 = sdiv i32 %t9, %t10
%t12 = load i32, i32* %t0
%t13 = sub nsw i32 %t11, %t12
%t14 = load i32, i32* %t2
%t15 = load i32, i32* %t0
%t16 = load i32, i32* %t1
%t17 = mul nsw i32 2, %t16
%t18 = add nsw i32 %t15, %t17
%t19 = mul nsw i32 %t14, %t18
%t20 = add nsw i32 %t13, %t19
store i32 %t20, i32* %t2, align 4
%t22 = load i32, i32* %t0
%t23 = load i32, i32* %t2
%t21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @str1, i64 0, i64 0), i32 %t22, i32 %t23)
%t24 = load i32, i32* %t0
%t25 = load i32, i32* %t1
%t26 = add nsw i32 %t24, %t25
%t27 = load i32, i32* %t2
%t28 = load i32, i32* %t0
%t29 = mul nsw i32 %t28, 20
%t30 = mul nsw i32 %t27, %t29
%t31 = add nsw i32 1, 1
%t32 = sdiv i32 %t30, %t31
%t33 = sub nsw i32 %t26, %t32
%t34 = mul nsw i32 2, 3
%t35 = mul nsw i32 %t34, 4
%t36 = sub nsw i32 %t33, %t35
store i32 %t36, i32* %t0, align 4
%t38 = load i32, i32* %t0
%t37 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str2, i64 0, i64 0), i32 %t38)
%t39 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @str3, i64 0, i64 0))
ret i32 0
}
