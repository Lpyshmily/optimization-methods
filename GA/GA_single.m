function [xv, fv] = GA_single(fitness, a, b, NP, NG, Pc, Pm, eps)
% 基本遗传算法，一维无约束优化
% 待优化的目标函数：fitness
% 自变量下界：a
% 自变量上界：b
% 种群个体数：NP
% 最大进化代数：NG
% 杂交常数：Pc
% 变异常数：Pm
% 自变量离散精度：eps
% 目标函数取最大值是的自变量值：xv
% 目标函数的最小值：fv
L = ceil(log2((b-a)/eps + 1));  % 染色体长度

% 初始化种群
x = zeros(NP, L);
fx = zeros(NP, 1);
for i=1:NP
    x(i,:) = Initial(L);
    fx(i) = fitness(Bin2Dec(a, b, x(i,:), L));
end

% 进化过程
x_new = zeros(NP, L);
fx_new = zeros(NP, 1);
xv = zeros(1,L);
fv = 0;
flag = true;  % 判断是否为第一代的标志
for i=1:NG
    % 按适应度函数从大到小排序
    [fx, descend_index] = sort(fx, 'descend');
    x = x(descend_index, :);
    % 记录本次最优解
    best_x = x(1, :);
    best_fx = fx(1);
%     fprintf('第%d代\n', i);
%     fprintf('%d', best_x);
%     fprintf('\nbest_x: %f\n', Bin2Dec(a, b, best_x, L));
%     fprintf('best_fx: %f\n', best_fx);
    % 记录当前最优解
    if flag
        xv = Bin2Dec(a, b, best_x, L);
        fv = best_fx;
        flag = false;
    else
        if best_fx > fv
            xv = Bin2Dec(a, b, best_x, L);
            fv = best_fx;
        end
    end
    % 计算概率和累积概率
    min_fx = fx(end);
    if min_fx < 0
        change_fx = fx - min_fx + 5;  % 保证概率为正
    else
        change_fx = fx;
    end
    sum_fx = sum(change_fx);
    Px = change_fx / sum_fx;  % 概率
    PPx = cumsum(Px);  % 累积概率
    % 选择和交叉
    % 选择两个父代，然后进行交叉，较好的一个子代进入x_new中，共进行NP次，产生NP个子代
    for j=1:NP
        % 轮盘赌选择两个父代索引
        for k=1:NP
            possiblity = rand();
            if possiblity <= PPx(k)
                index_father = k;
                break;
            end
        end
        for k=1:NP
            possiblity = rand();
            if possiblity <= PPx(k)
                index_mother = k;
                break;
            end
        end
        % 
        % 如果两个父代相同，则不进行交叉，直接进入子代
        if index_father == index_mother
            x_new(j, :) = x(index_father, :);
            fx_new(j) = fx(index_father);
            continue;
        end
        % 按概率判断是否进行交叉
        possiblity = rand();
        if possiblity < Pc
            % 随机确定交叉点
            possiblity = rand();
            cut_position = ceil(possiblity*(L-1));
            % 交叉
            temp1 = [x(index_father, 1:cut_position) x(index_mother, cut_position+1:end)];
            temp2 = [x(index_mother, 1:cut_position) x(index_father, cut_position+1:end)];
            fx_temp1 = fitness(Bin2Dec(a, b, temp1, L));
            fx_temp2 = fitness(Bin2Dec(a, b, temp2, L));
            if fx_temp1 > fx_temp2
                x_new(j, :) = temp1;
                fx_new(j) = fx_temp1;
            else
                x_new(j, :) = temp2;
                fx_new(j) = fx_temp2;
            end
        else
            % 如果不进行交叉，直接让较好的一个父代进入子代
            if fx(index_father) > fx(index_mother)
                x_new(j, :) = x(index_father, :);
                fx_new(j) = fx(index_father);
            else
                x_new(j, :) = x(index_mother, :);
                fx_new(j) = fx(index_mother);
            end
        end
        
        % 新个体变异
        possibility = rand();
        if possibility < Pm
            possibility = rand();
            mut_position = ceil(possibility*L);  % 变异位置
            x_new(j, mut_position) = ~x_new(j, mut_position);
            fx_new(j) = fitness(Bin2Dec(a, b, x_new(j, :), L));
        end
    end
    x = x_new;
    fx = fx_new;
end
end

function result = Initial(length)  % 初始化函数
    result = zeros(1, length);
    for i=1:length
        r = rand();
        result(i) = round(r);
    end
end

function y = Bin2Dec(a, b, x, L)  % 二进制转十进制
    base = 2.^((L-1):-1:0);
    y = dot(base, x);
    y = a + y*(b-a)/(2^L - 1);
end