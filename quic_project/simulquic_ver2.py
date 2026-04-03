#!/usr/bin/python

from mininet.node import Controller, OVSKernelSwitch, Host
from mininet.log import setLogLevel, info
from mn_wifi.net import Mininet_wifi
from mn_wifi.node import OVSKernelAP
from mn_wifi.cli import CLI
import os

def myNetwork():
    net = Mininet_wifi(topo=None,
                       build=False,
                       ipBase='192.168.0.0/24')

    info( '*** Adding controller\n' )
    c0 = net.addController(name='c0',
                           controller=Controller,
                           port=6653)

    info( '*** Add switches/APs\n')
    s1 = net.addSwitch('s1', cls=OVSKernelSwitch)
    
    ap1 = net.addAccessPoint('ap1', cls=OVSKernelAP, ssid='simple-wifi',
                             channel='36', mode='a', position='300.0,400.0,0', range=350)

    ap2 = net.addAccessPoint('ap2', cls=OVSKernelAP, ssid='simple-wifi',
                             channel='40', mode='a', position='700.0,400.0,0', range=350)

    info( '*** Add hosts/stations\n')
    h1 = net.addHost('h1', cls=Host, ip='192.168.10.100/24', mac='00:00:00:00:00:10')
    
    sta1 = net.addStation('sta1', ip='192.168.10.10/24', mac='00:00:00:00:00:01',
                           bgscan_module='simple:1:-45:1',
                           position='200.0,400.0,0')

    info("*** Configuring Propagation Model\n")
    net.setPropagationModel(model="logDistance", exp=3.5)

    info("*** Configuring wifi nodes\n")
    net.configureWifiNodes()

    info( '*** Add links\n')
    net.addLink(h1, s1, bw=10)
    net.addLink(s1, ap1)
    net.addLink(s1, ap2)

    net.plotGraph(max_x=1000, max_y=1000)
    
    # Mobilitas
    net.startMobility(time=0)
    net.mobility(sta1, 'start', time=10, position='200.0,400.0,0')
    net.mobility(sta1, 'stop', time=120, position='800.0,400.0,0')
    net.stopMobility(time=130)

    info( '*** Starting network\n')
    net.build()
    c0.start()
    
    info( '*** Starting switches/APs\n')
    net.get('s1').start([c0])
    net.get('ap1').start([c0])
    net.get('ap2').start([c0])
    
    info( '*** Setting OpenFlow Normal Action...\n')
    s1.cmd('ovs-ofctl add-flow s1 priority=100,actions=NORMAL')

    info( '*** Setting Static ARP...\n')
    sta1.cmd('arp -s 192.168.10.100 00:00:00:00:00:10')
    h1.cmd('arp -s 192.168.10.10 00:00:00:00:00:01')
    
    info( '*** Menyiapkan Server Caddy ***\n')
    current_dir = os.getcwd()
    h1.cmd('cd %s' % current_dir)
    
    info( '*** Network Ready. Silahkan jalankan xterm h1 dan xterm sta1 dari CLI ***\n')

    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    myNetwork()
