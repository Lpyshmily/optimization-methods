# 遗传算法求解一元函数极大值
# 参考 https://blog.csdn.net/saltriver/article/details/63679701
import numpy as np
import matplotlib.pyplot as plt


# 适应度函数
def fitness(x):
    return x + 10 * np.sin(5 * x) + 7 * np.cos(4 * x)


# 个体类
class Individual:
    def __init__(self):
        self.x = 0  # 染色体编码
        self.fitness = 0  # 适应度值


# 随机初始化种群列表pop，含有N个个体
def initPopulation(pop, N):
    for i in range(N):
        ind = Individual()
        ind.x = np.random.uniform(-10, 10)  # 随机生成10到10之间的浮点数
        ind.fitness = fitness(ind.x)
        pop.append(ind)


# 选择过程，返回一组随机数
def selection(N):
    # 种群中随机选择2个个体（这里没有用轮盘赌，直接用的随机选择）
    return np.random.choice(N, 2)


# 结合/交叉过程，返回两个新的个体
def crossover(parent1, parent2):
    child1, child2 = Individual(), Individual()
    child1.x = 0.9 * parent1.x + 0.1 * parent2.x
    child2.x = 0.1 * parent1.x + 0.9 * parent2.x
    child1.fitness = fitness(child1.x)
    child2.fitness = fitness(child2.x)
    return child1, child2


# 变异过程
def mutation(pop):
    # 种群中随机选择一个个体进行变异
    ind = np.random.choice(pop)
    # 用随机赋值的方式进行变异
    ind.x = np.random.uniform(-10, 10)
    ind.fitness = fitness(ind.x)


# 最终执行
def implement():
    N = 20  # 种群中个体数量
    POP = []  # 种群列表
    iter_N = 500  # 迭代次数
    initPopulation(POP, N)  # 初始化种群

    # 进化过程
    for it in range(iter_N):
        if np.random.random() < 0.75:  # 以0.75的概率进行交叉结合
            a, b = selection(N)  # 随机选出两个序号
            child1, child2 = crossover(POP[a], POP[b])
            new = sorted([POP[a], POP[b], child1, child2], key=lambda ind: ind.fitness, reverse=True)  # 按照适应度函数降序排列
            POP[a], POP[b] = new[0], new[1]  # 从四个个体中保留最好的两个

        if np.random.random() < 0.1:  # 以0.1的概率进行变异
            mutation(POP)

        POP.sort(key=lambda ind: ind.fitness, reverse=True)  # 种群中所有个体按照适应度函数降序排列

        # 将每一代最好的个体进行输出
        # print("第%3d代" % (it + 1), POP[0].x, POP[0].fitness)

    return POP


if __name__ == "__main__":
    pop = implement()
    # 输出最后一代的所有个体
    for each in pop:
        print(each.x, each.fitness)
    # 绘图代码
    x = np.linspace(-10, 10, 10000)
    y = fitness(x)
    scatter_x = np.array([ind.x for ind in pop])
    scatter_y = np.array([ind.fitness for ind in pop])
    plt.plot(x, y)
    plt.scatter(scatter_x, scatter_y, s=10, c='r')
    plt.show()
