import matplotlib.pyplot as plt
import pandas as pd
data = pd.read_excel('ibe/concentration.xlsx')

x = data['Concentration']
y = data['Absorption']

plt.plot(x,y,color='orange')
plt.title('Absorption curve for wavelength = 500nm')
plt.xlabel('Concentration (M)')
plt.ylabel('Absorption')
plt.show()