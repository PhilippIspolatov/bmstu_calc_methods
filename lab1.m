global mode;
global solution;
mode = "DEBUG";
solution = "MIN";

[matr, count] = ReadDataFromFile('test2.txt');
Method(matr, count);

function Method(matr, count)
    src = matr;
    global mode;
    global solution;
    if mode == "DEBUG"
        printMatrix(matr, count);
    end
    if solution == "MAX"
        matr = ToMax(matr, count);
        if mode == "DEBUG"
            fprintf("Inverse\n");
            printMatrix(matr, count);
        end
    end
    matr = MinusRow(matr, count);
    if mode == "DEBUG"
        printMatrix(matr, count);
    end
    matr = MinusCol(matr, count);
    if mode == "DEBUG"
        printMatrix(matr, count);
    end
    [matr, countStar] = MarkByStar(matr, count);
    if mode == "DEBUG"
        printMatrix(matr, count);
    end
    
    for iter = 1:count-countStar + 1
    
        [selectedColmns, selectedRows] = SelectColumns(matr, count);
        [matr, row, col] = ResolveMatrix(matr, selectedColmns, selectedRows, count);
        [imas, jmas] = LChain(matr, count, row, col);
        if mode == "DEBUG"
            printMatrix(matr, count);
        end
        matr = Replace(matr, imas, jmas);
        if mode == "DEBUG"
            printMatrix(matr, count);
        end
        res = Result(src, matr, count);
    end
end

function [matr] = ToMax(matr, count)
    max = matr{1, 1}.value;
    for i = 1:count
        for j = 1:count
            if matr{i,j}.value > max
                max = matr{i,j}.value;
            end
        end
    end
    for i = 1:count
        for j = 1:count
        	matr{i,j}.value = matr{i,j}.value * -1;
        end
    end
    for i = 1:count
        for j = 1:count
        	matr{i,j}.value = matr{i,j}.value + max;
        end
    end
end

function [matrix, count] = ReadDataFromFile(filename)
     fileID = fopen(filename, 'r');

     count = fscanf(fileID, '%d', 1);

     matrix = {cell(count, count)};

     for i = 1:count
         for j = 1:count
             value = fscanf(fileID, '%f', 1);
             matrix{i,j} = struct('value', value, 'mark', '');
         end
     end
     fclose(fileID);
end
 
function [matrix] = MinusRow(matrix, count)
    x = matrix{1,:};
    for i = 1:count
        min = matrix{i, 1}.value;
        for j = 1:count
            if matrix{i, j}.value < min
                min = matrix{i, j}.value;
            end
        end
        for j = 1:count
            matrix{i, j}.value = matrix{i, j}.value - min;
        end
    end
end
 
function [matrix] = MinusCol(matrix, count)
    x = matrix{1,:};
    for i = 1:count
        min = matrix{1, i}.value;
        for j = 1:count
            if matrix{j, i}.value < min
                min = matrix{j, i}.value;
            end
        end
        for j = 1:count
            matrix{j, i}.value = matrix{j, i}.value - min;
        end
    end
end
 
function printMatrix(matr, count)
    for i = 1:count
        for j = 1:count
            fprintf('%f(%s) ', matr{i, j}.value, matr{i, j}.mark);
        end
        fprintf('\n');
    end
    fprintf('\n');
end
  
function [isEqual] = isEqual(toCompare, value)
    isEqual = false;
    if toCompare == value
        isEqual = true;
    end
    return;
end
  
function [isValid, p] = isHaveStarZeroInRow(matr, row, count)
    p = -1;
    isValid = false;
    for i = 1:count
        if isEqual(matr{row,i}.value, 0) && isEqual(matr{row,i}.mark, '*')
            isValid = true;
            p = i;
            return;
        end
    end
end
  
function [matrix, countStar] = MarkByStar(matrix, count)
    countStar = 0;
    for i = 1:count
        for j = 1:count
            if matrix{j, i}.value == 0
                [r, ~] = isHaveStarZeroInRow(matrix, j, count);
                if r == false
                    matrix{j, i}.mark = '*';
                    countStar = countStar + 1;
                    break;
                end
            end
        end  
    end
end
  
function [selectedColumns, selectedRows] = SelectColumns(matr, count)
    selectedColumns = zeros(1, count);
    selectedRows = zeros(1, count);
  for i = 1:count
      for j = 1:count
          if matr{j, i}.mark == '*'
              selectedColumns(i) = 1;
          end
      end
  end
end
  
% ?
function [matrix, row, col] = ResolveMatrix(matrix, slctdCols, slctdRows, count)
    global mode;
    while 1
        haveZeros = false;
        if mode == "DEBUG"
            printMatrix(matrix, count);
        end
        flag = true;
        for i = 1:count
            if slctdCols(i) == 0 && flag == true
                for j = 1:count
                    if slctdRows(j) == 0 && flag == true
                        if isEqual(matrix{j, i}.value, 0) && ~isEqual(matrix{j, i}.mark, '*')
                            haveZeros = true;
                            matrix{j, i}.mark = '.';
                            [r, p] = isHaveStarZeroInRow(matrix, j, count);
                            if r
                                slctdRows(j) = 1;
                                slctdCols(p) = 0;
                                flag = false;
                                break;
                            end
                            if ~r
                                row = j;
                                col = i;
                                return;
                            end
                        end
                    end
                end
            end
        end
        if haveZeros ~= true
            min = 99999999999;
            for i = 1:count
                if slctdCols(i) == 0
                    for j = 1:count
                        if slctdRows(j) == 0
                            if matrix{j, i}.value < min
                                min = matrix{j, i}.value;
                            end
                        end
                    end
                    
                end
            end
            for i = 1:length(slctdCols)
                if slctdCols(i) == 0
                    for j = 1:count
                        matrix{j,i}.value = matrix{j,i}.value - min;
                    end
                    
                end
            end
            for i = 1:length(slctdRows)
                if slctdRows(i) == 1
                    for j = 1:count
                        matrix{i,j}.value = matrix{j,i}.value + min;
                    end
                    
                end
            end
        end
    end
end

% min / max

function [row, col] = FindNextChain(matr, count, mark, ipos, jpos)
    row = -1;
    col = -1;
    if mark == '.'
        for i = 1:count
            if matr{i,jpos}.mark == '*'
                row = i;
                col = jpos;
                return;
            end
        end
    end
    if mark == '*'
        for j = 1:count
            if matr{ipos,j}.mark == '.'
                row = ipos;
                col = j;
                return;
            end
        end
    end
end

function [imas, jmas] = LChain(matrix, count, row, col)
    imas = zeros(1, count);
    jmas = zeros(1, count);
    i = 1;
    while row ~= -1 && col ~= -1
        imas(i) = row;
        jmas(i) = col;
        [row, col] = FindNextChain(matrix, count, matrix{row, col}.mark, row, col);
        i = i + 1;
    end
end

function [matrix] = Replace(matrix, imas, jmas)
    for i = 1:length(imas)
        if matrix{imas(i),jmas(i)}.mark == '*'
            matrix{imas(i),jmas(i)}.mark = '';
        end
        if matrix{imas(i),jmas(i)}.mark == '.'
            matrix{imas(i),jmas(i)}.mark = '*';
        end 
    end
end

function res = Result(src, matr, count)
    res = 0;
    for i = 1:count
        for j = 1:count
            if matr{i, j}.mark == '*'
                res = res + src{i, j}.value;
            end
        end
    end
    fprintf('%f', res);
end



