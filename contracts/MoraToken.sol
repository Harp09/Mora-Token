// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Definición del contrato MoraToken
contract MoraToken is ERC20, Ownable {
    // Tasa de conversión por red
    mapping(uint256 => uint256) public conversionRates; // Almacena el valor de conversión de 1 ETH a Mora Token por red

    // El constructor inicializa el token con un nombre, símbolo, y una tasa de conversión por defecto
    constructor(uint256 initialSupply) 
    ERC20("MoraToken", "MORA") // Inicializa ERC20 con nombre y símbolo
    Ownable(msg.sender) // Llama al constructor de Ownable y pasa la dirección del propietario
{
    _mint(msg.sender, initialSupply * (10 ** decimals())); // Minta el suministro inicial a la dirección del propietario
        // Definir valores por red: Holesky = 3 MORA por ETH, Sepolia = 10 MORA por ETH
        conversionRates[11155111] = 10; // Sepolia
        conversionRates[17000] = 3; // Holesky
    }

    // Función para cambiar la tasa de conversión en una red específica
    function setConversionRate(uint256 networkId, uint256 rate) external onlyOwner {
        conversionRates[networkId] = rate;
    }

    // Función para adquirir Mora Tokens según la tasa de conversión de la red actual
    function buyMoraToken() external payable {
        require(msg.value > 0, "Debes enviar ETH para comprar Mora Tokens");

        // Obtener el network ID (en un entorno real, usaría block.chainid)
        uint256 networkId = block.chainid;

        // Verificar si existe una tasa de conversión para esta red
        require(conversionRates[networkId] > 0, "No existe tasa de conversion para esta red");

        // Calcular el número de Mora Tokens a entregar
        uint256 moraTokens = msg.value * conversionRates[networkId];

        // Transferir Mora Tokens al comprador
        _mint(msg.sender, moraTokens);
    }

    // Función para realizar transferencias de Mora Tokens a otra cuenta
    function transferMoraTokens(address recipient, uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "No tienes suficientes Mora Tokens");
        _transfer(msg.sender, recipient, amount);
    }

    // Función para retirar los fondos en ETH del contrato por el dueño
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
