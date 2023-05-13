import matplotlib.pyplot as plt
import pandas as pd
data = pd.read_excel('ibe/ibelab5.xlsx')

x = data['X']
y = data['Y']

plt.plot(x,y,color="orange")
plt.title('Absorption spectrum of Sucrose sample-5')
plt.xlabel('Wavelength(nm)')
plt.ylabel('Absorption')
plt.show()