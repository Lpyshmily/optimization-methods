function [xv, fv] = GA_single(fitness, a, b, NP, NG, Pc, Pm, eps)
% �����Ŵ��㷨��һά��Լ���Ż�
% ���Ż���Ŀ�꺯����fitness
% �Ա����½磺a
% �Ա����Ͻ磺b
% ��Ⱥ��������NP
% ������������NG
% �ӽ�������Pc
% ���쳣����Pm
% �Ա�����ɢ���ȣ�eps
% Ŀ�꺯��ȡ���ֵ�ǵ��Ա���ֵ��xv
% Ŀ�꺯������Сֵ��fv
L = ceil(log2((b-a)/eps + 1));  % Ⱦɫ�峤��

% ��ʼ����Ⱥ
x = zeros(NP, L);
fx = zeros(NP, 1);
for i=1:NP
    x(i,:) = Initial(L);
    fx(i) = fitness(Bin2Dec(a, b, x(i,:), L));
end

% ��������
x_new = zeros(NP, L);
fx_new = zeros(NP, 1);
xv = zeros(1,L);
fv = 0;
flag = true;  % �ж��Ƿ�Ϊ��һ���ı�־
for i=1:NG
    % ����Ӧ�Ⱥ����Ӵ�С����
    [fx, descend_index] = sort(fx, 'descend');
    x = x(descend_index, :);
    % ��¼�������Ž�
    best_x = x(1, :);
    best_fx = fx(1);
%     fprintf('��%d��\n', i);
%     fprintf('%d', best_x);
%     fprintf('\nbest_x: %f\n', Bin2Dec(a, b, best_x, L));
%     fprintf('best_fx: %f\n', best_fx);
    % ��¼��ǰ���Ž�
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
    % ������ʺ��ۻ�����
    min_fx = fx(end);
    if min_fx < 0
        change_fx = fx - min_fx + 5;  % ��֤����Ϊ��
    else
        change_fx = fx;
    end
    sum_fx = sum(change_fx);
    Px = change_fx / sum_fx;  % ����
    PPx = cumsum(Px);  % �ۻ�����
    % ѡ��ͽ���
    % ѡ������������Ȼ����н��棬�Ϻõ�һ���Ӵ�����x_new�У�������NP�Σ�����NP���Ӵ�
    for j=1:NP
        % ���̶�ѡ��������������
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
        % �������������ͬ���򲻽��н��棬ֱ�ӽ����Ӵ�
        if index_father == index_mother
            x_new(j, :) = x(index_father, :);
            fx_new(j) = fx(index_father);
            continue;
        end
        % �������ж��Ƿ���н���
        possiblity = rand();
        if possiblity < Pc
            % ���ȷ�������
            possiblity = rand();
            cut_position = ceil(possiblity*(L-1));
            % ����
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
            % ��������н��棬ֱ���ýϺõ�һ�����������Ӵ�
            if fx(index_father) > fx(index_mother)
                x_new(j, :) = x(index_father, :);
                fx_new(j) = fx(index_father);
            else
                x_new(j, :) = x(index_mother, :);
                fx_new(j) = fx(index_mother);
            end
        end
        
        % �¸������
        possibility = rand();
        if possibility < Pm
            possibility = rand();
            mut_position = ceil(possibility*L);  % ����λ��
            x_new(j, mut_position) = ~x_new(j, mut_position);
            fx_new(j) = fitness(Bin2Dec(a, b, x_new(j, :), L));
        end
    end
    x = x_new;
    fx = fx_new;
end
end

function result = Initial(length)  % ��ʼ������
    result = zeros(1, length);
    for i=1:length
        r = rand();
        result(i) = round(r);
    end
end

function y = Bin2Dec(a, b, x, L)  % ������תʮ����
    base = 2.^((L-1):-1:0);
    y = dot(base, x);
    y = a + y*(b-a)/(2^L - 1);
end